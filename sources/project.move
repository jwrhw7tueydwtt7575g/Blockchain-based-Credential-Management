module OnChainStudent::MessageBoard {
    use std::string::{String, utf8};
    use std::signer;

    struct Message has key {
        my_message: String,
    }

    public entry fun store_message(account: &signer, msg: String) acquires Message {
        let addr = signer::address_of(account);
        if (!exists<Message>(addr)) {
            move_to(account, Message { my_message: msg });
            return
        };
        let m = borrow_global_mut<Message>(addr);
        m.my_message = msg;
    }

    public fun read_message(owner: address): String acquires Message {
        let m = borrow_global<Message>(owner);
        m.my_message
    }

    #[test(admin = @0x1234)]
    public entry fun test_store_message(admin: signer) acquires Message {
        // write twice
        store_message(&admin, utf8(b"first"));
        store_message(&admin, utf8(b"second"));
        let got = read_message(signer::address_of(&admin));
        // basic assert by string equality check (fails test if not equal)
        assert!(got == utf8(b"second"), 1);
    }
}
