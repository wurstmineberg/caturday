{
    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    outputs = attrs: {
        nixosConfigurations = {
            bootstrap = attrs.nixpkgs.lib.nixosSystem {
                modules = [
                    ({ lib, modulesPath, ... }: {
                        imports = [
                            "${modulesPath}/virtualisation/linode-config.nix"
                        ];
                        nixpkgs.hostPlatform = "x86_64-linux";
                        system.stateVersion = "25.11"; # should NEVER be changed, see Nix option description
                    })
                ];
                specialArgs = attrs;
            };
            caturday = attrs.nixpkgs.lib.nixosSystem {
                modules = [
                    ({ lib, modulesPath, ... }: {
                        imports = [
                            "${modulesPath}/virtualisation/linode-config.nix"
                        ];
                        nixpkgs.hostPlatform = "x86_64-linux";
                        system.stateVersion = "25.11"; # should NEVER be changed, see Nix option description
                    })
                ];
                specialArgs = attrs;
            };
        };
    };
}
