builtins.listToAttrs
    (builtins.map
        (name: {
            name = "secrets/${name}";
            value.publicKeys = builtins.filter
                (key: builtins.match "ssh-ed25519 .+" key != null)
                (builtins.attrValues (import ./authorized-keys.nix));
        })
        ((builtins.attrNames
            (builtins.readDir ./secrets)
        ) ++ [
            # to add a new secret, add the filename here (as a string)
        ])
    )
