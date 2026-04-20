builtins.listToAttrs
    (builtins.map
        (name: {
            name = "secrets/${name}";
            value.publicKeys = builtins.filter
                (key: builtins.match "ssh-ed25519 .+" key != null)
                (builtins.attrValues (import assets/authorized-keys.nix))
            ++ [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIFN9OhRDerFtfKKNTTzxMxWr4Rl/y5b2B7j5zeJZocA" # caturday's host key
            ];
        })
        ((builtins.attrNames
            (builtins.readDir ./secrets)
        ) ++ [
            # to add a new secret, add the filename here (as a string)
        ])
    )
