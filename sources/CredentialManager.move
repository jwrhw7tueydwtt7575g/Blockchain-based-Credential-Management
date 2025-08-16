module OnChainStudent::CredentialManager {
    use std::signer;
    use std::vector;

    use OnChainStudent::CredentialSchema;
    use OnChainStudent::IssuerRegistry;

    /// Error codes
    const E_NOT_INITIALIZED: u64 = 1;
    const E_ALREADY_INITIALIZED: u64 = 2;
    const E_UNAUTHORIZED_ISSUER: u64 = 3;
    const E_SCHEMA_NOT_FOUND: u64 = 4;

    /// A verifiable credential record
    struct Credential has copy, drop, store {
        id: u64,
        student: address,
        issuer: address,
        schema_id: u64,
        hash: vector<u8>,
        ipfs_uri: vector<u8>,
        revoked: bool,
        reason_code: u8,
    }

    /// Store kept under the admin address
    struct CredentialStore has key {
        next_id: u64,
        credentials: vector<Credential>,
    }

    /// Initialize under the admin account
    public entry fun init(admin: &signer) {
        let admin_addr = signer::address_of(admin);
        if (exists<CredentialStore>(admin_addr)) {
            abort E_ALREADY_INITIALIZED;
        };
        move_to(admin, CredentialStore { next_id: 1, credentials: vector::empty<Credential>() });
    }

    /// Issue a credential. The caller must be a trusted issuer in IssuerRegistry at `admin_addr`.
    /// Also requires that `schema_id` exists in CredentialSchema at `admin_addr`.
    public entry fun issue_credential(
        issuer: &signer,
        admin_addr: address,
        student: address,
        schema_id: u64,
        hash: vector<u8>,
        ipfs_uri: vector<u8>
    ) acquires CredentialStore {
        // Verify issuer is trusted
        let issuer_addr = signer::address_of(issuer);
        if (!IssuerRegistry::is_trusted_issuer(admin_addr, issuer_addr)) {
            abort E_UNAUTHORIZED_ISSUER;
        };
        // Verify schema exists
        if (!CredentialSchema::has_schema(admin_addr, schema_id)) {
            abort E_SCHEMA_NOT_FOUND;
        };

        assert_store_exists(admin_addr);
        let store = borrow_global_mut<CredentialStore>(admin_addr);
        let id = store.next_id;
        let cred = Credential {
            id,
            student,
            issuer: issuer_addr,
            schema_id,
            hash,
            ipfs_uri,
            revoked: false,
            reason_code: 0,
        };
        vector::push_back(&mut store.credentials, cred);
        store.next_id = id + 1;
    }

    /// Revoke a credential by id. Only the original issuer may revoke.
    public entry fun revoke_credential(issuer: &signer, admin_addr: address, cred_id: u64, reason_code: u8) acquires CredentialStore {
        let issuer_addr = signer::address_of(issuer);
        assert_store_exists(admin_addr);
        let store = borrow_global_mut<CredentialStore>(admin_addr);
        let creds_ref = &mut store.credentials;
        let len = vector::length(creds_ref);
        revoke_helper(creds_ref, cred_id, issuer_addr, reason_code, 0, len);
    }

    /// Return a credential (copied) by id
    public fun get_credential(admin_addr: address, cred_id: u64): Credential acquires CredentialStore {
        assert_store_exists(admin_addr);
        let store = borrow_global<CredentialStore>(admin_addr);
        let creds_ref = &store.credentials;
        let len = vector::length(creds_ref);
        get_helper(creds_ref, cred_id, 0, len)
    }

    fun revoke_helper(creds: &mut vector<Credential>, cred_id: u64, issuer_addr: address, reason_code: u8, i: u64, len: u64) {
        if (i >= len) { return };
        let c_ref = vector::borrow_mut(creds, i);
        if (c_ref.id == cred_id) {
            if (c_ref.issuer == issuer_addr) {
                c_ref.revoked = true;
                c_ref.reason_code = reason_code;
            };
            return
        };
        revoke_helper(creds, cred_id, issuer_addr, reason_code, i + 1, len)
    }

    fun get_helper(creds: &vector<Credential>, cred_id: u64, i: u64, len: u64): Credential {
        if (i >= len) { abort E_NOT_INITIALIZED };
        let c_ref = vector::borrow(creds, i);
        if (c_ref.id == cred_id) { return *c_ref }; // return a copy
        get_helper(creds, cred_id, i + 1, len)
    }

    fun assert_store_exists(admin_addr: address) {
        if (!exists<CredentialStore>(admin_addr)) {
            abort E_NOT_INITIALIZED;
        };
    }
}
