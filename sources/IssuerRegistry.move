module OnChainStudent::IssuerRegistry {
    use std::signer;
    use std::vector;

    /// Error codes
    const E_NOT_INITIALIZED: u64 = 1;
    const E_ALREADY_INITIALIZED: u64 = 2;
    const E_NOT_ADMIN: u64 = 3;

    /// Issuer info
    struct Issuer has copy, drop, store {
        addr: address,
        name: vector<u8>,
    }

    /// Registry stored under the admin's address
    struct Registry has key {
        admin: address,
        issuers: vector<Issuer>,
    }

    /// Initialize the issuer registry
    public entry fun init(admin: &signer) {
        let admin_addr = signer::address_of(admin);
        if (exists<Registry>(admin_addr)) {
            abort E_ALREADY_INITIALIZED;
        };
        move_to(admin, Registry { admin: admin_addr, issuers: vector::empty<Issuer>() });
    }

    /// Only admin can add an issuer
    public entry fun add_issuer(admin: &signer, issuer_addr: address, name: vector<u8>) acquires Registry {
        let admin_addr = signer::address_of(admin);
        assert_registry_exists(admin_addr);
        let reg = borrow_global_mut<Registry>(admin_addr);
        assert_is_admin(reg, admin_addr);
        let iss = Issuer { addr: issuer_addr, name };
        vector::push_back(&mut reg.issuers, iss);
    }

    /// Only admin can remove an issuer (by address)
    public entry fun remove_issuer(admin: &signer, issuer_addr: address) acquires Registry {
        let admin_addr = signer::address_of(admin);
        assert_registry_exists(admin_addr);
        let reg = borrow_global_mut<Registry>(admin_addr);
        assert_is_admin(reg, admin_addr);
        let len = vector::length(&reg.issuers);
        remove_helper(&mut reg.issuers, issuer_addr, 0, len);
    }

    /// Check if an address is a trusted issuer
    public fun is_trusted_issuer(admin_addr: address, issuer_addr: address): bool acquires Registry {
        if (!exists<Registry>(admin_addr)) {
            return false
        };
        let reg = borrow_global<Registry>(admin_addr);
        let iss_ref = &reg.issuers;
        let len = vector::length(iss_ref);
        contains_helper(iss_ref, issuer_addr, 0, len)
    }

    fun remove_helper(v: &mut vector<Issuer>, issuer_addr: address, i: u64, len: u64) {
        if (i >= len) { return };
        let iss_ref = vector::borrow(v, i);
        if (iss_ref.addr == issuer_addr) {
            vector::remove(v, i);
            return
        };
        remove_helper(v, issuer_addr, i + 1, len)
    }

    fun contains_helper(v: &vector<Issuer>, issuer_addr: address, i: u64, len: u64): bool {
        if (i >= len) { return false };
        let iss_ref = vector::borrow(v, i);
        if (iss_ref.addr == issuer_addr) { return true };
        contains_helper(v, issuer_addr, i + 1, len)
    }

    fun assert_registry_exists(admin_addr: address) {
        if (!exists<Registry>(admin_addr)) {
            abort E_NOT_INITIALIZED;
        };
    }

    fun assert_is_admin(registry: &Registry, caller: address) {
        if (registry.admin != caller) {
            abort E_NOT_ADMIN;
        };
    }
}
