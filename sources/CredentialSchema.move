module OnChainStudent::CredentialSchema {
    use std::signer;
    use std::vector;

    /// Error codes
    const E_NOT_INITIALIZED: u64 = 1;
    const E_ALREADY_INITIALIZED: u64 = 2;
    const E_SCHEMA_NOT_FOUND: u64 = 3;
    const E_NOT_ADMIN: u64 = 4;

    /// A credential schema definition
    struct Schema has copy, drop, store {
        id: u64,
        name: vector<u8>,
        version: vector<u8>,
        ipfs_uri: vector<u8>,
        creator: address,
    }

    /// Registry stored under the admin's address
    struct SchemaRegistry has key {
        admin: address,
        schemas: vector<Schema>,
        next_id: u64,
    }

    /// Publish the registry under the admin account (call once)
    public entry fun init(admin: &signer) {
        let admin_addr = signer::address_of(admin);
        if (exists<SchemaRegistry>(admin_addr)) {
            abort E_ALREADY_INITIALIZED;
        };
        move_to(admin, SchemaRegistry {
            admin: admin_addr,
            schemas: vector::empty<Schema>(),
            next_id: 1,
        });
    }

    /// Only the admin can add schemas
    public entry fun add_schema(admin: &signer, name: vector<u8>, version: vector<u8>, ipfs_uri: vector<u8>) acquires SchemaRegistry {
        let admin_addr = signer::address_of(admin);
        assert_registry_exists(admin_addr);
        let registry = borrow_global_mut<SchemaRegistry>(admin_addr);
        assert_is_admin(registry, admin_addr);
        let id = registry.next_id;
        let schema = Schema { id, name, version, ipfs_uri, creator: admin_addr };
        vector::push_back(&mut registry.schemas, schema);
        registry.next_id = id + 1;
    }

    /// Return a schema (copied) by id
    public fun get_schema(admin_addr: address, schema_id: u64): Schema acquires SchemaRegistry {
        assert_registry_exists(admin_addr);
        let registry = borrow_global<SchemaRegistry>(admin_addr);
        let schemas_ref = &registry.schemas;
        let len = vector::length(schemas_ref);
        get_schema_helper(schemas_ref, schema_id, 0, len)
    }

    /// Returns true if a schema id exists
    public fun has_schema(admin_addr: address, schema_id: u64): bool acquires SchemaRegistry {
        if (!exists<SchemaRegistry>(admin_addr)) {
            return false
        };
        let registry = borrow_global<SchemaRegistry>(admin_addr);
        let schemas_ref = &registry.schemas;
        let len = vector::length(schemas_ref);
        has_schema_helper(schemas_ref, schema_id, 0, len)
    }

    fun get_schema_helper(schemas: &vector<Schema>, schema_id: u64, i: u64, len: u64): Schema {
        if (i >= len) {
            abort E_SCHEMA_NOT_FOUND;
        };
        let s_ref = vector::borrow(schemas, i);
        if (s_ref.id == schema_id) {
            return *s_ref   // return a copy
        };
        get_schema_helper(schemas, schema_id, i + 1, len)
    }

    fun has_schema_helper(schemas: &vector<Schema>, schema_id: u64, i: u64, len: u64): bool {
        if (i >= len) {
            return false
        };
        let s_ref = vector::borrow(schemas, i);
        if (s_ref.id == schema_id) {
            return true
        };
        has_schema_helper(schemas, schema_id, i + 1, len)
    }

    fun assert_registry_exists(admin_addr: address) {
        if (!exists<SchemaRegistry>(admin_addr)) {
            abort E_NOT_INITIALIZED;
        };
    }

    fun assert_is_admin(registry: &SchemaRegistry, caller: address) {
        if (registry.admin != caller) {
            abort E_NOT_ADMIN;
        };
    }
}
