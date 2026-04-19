{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
        agenix = {
            url = "github:ryantm/agenix";
            inputs = {
                nixpkgs.follows = "nixpkgs";
                darwin.follows = ""; # don't download darwin deps (saves some resources on Linux)
            };
        };
        night-device-report = {
            url = "github:fenhl/night-device-report";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixos-needsreboot = {
            url = "github:fenhl/nixos-needsreboot";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };
    outputs = attrs: {
        nixosConfigurations = {
            bootstrap = attrs.nixpkgs.lib.nixosSystem {
                modules = [
                    ({ lib, modulesPath, pkgs, ... }: {
                        environment = {
                            loginShellInit = ''
                                # automatically switch to the full config on first boot
                                [[ "$(tty)" == /dev/ttyS0 ]] \
                                    && nixos-rebuild switch --recreate-lock-file --refresh --no-write-lock-file --flake=github:wurstmineberg/caturday \
                                    && ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
                            '';
                            systemPackages = with pkgs; [
                                git # required to switch to the caturday system config
                            ];
                        };
                        imports = [
                            "${modulesPath}/virtualisation/linode-config.nix"
                        ];
                        networking.hostName = "caturday";
                        nixpkgs.hostPlatform = "x86_64-linux";
                        services.getty.autologinUser = "root"; # automatically log in on startup to continue the bootstrap sequence
                        system.stateVersion = "25.11"; # should NEVER be changed, see Nix option description
                    })
                ];
                specialArgs = attrs;
            };
            caturday = attrs.nixpkgs.lib.nixosSystem {
                modules = [
                    attrs.agenix.nixosModules.default
                    {
                        # include all secrets as config entries by filename
                        age.secrets = builtins.listToAttrs
                            (builtins.map
                                (filename: {
                                    name = builtins.elemAt (builtins.match "(.+)\\.age" filename) 0;
                                    value.file = ./secrets/${filename};
                                })
                                (builtins.attrNames
                                    (builtins.readDir ./secrets)
                                )
                            );
                    }
                    ({ lib, modulesPath, pkgs, ... }: {
                        age.secrets."night.json".path = "/etc/xdg/fenhl/night.json"; # required for night-device-report
                        environment.systemPackages = with pkgs; [
                            git # required for system updates
                            htop # to debug running processes
                            ncdu # to debug full disks
                        ];
                        imports = [
                            "${modulesPath}/virtualisation/linode-config.nix"
                        ];
                        networking = {
                            firewall = {
                                allowedTCPPorts = [ 80 443 ]; # caddy #TODO (nixpkgs 26.05) replace with services.caddy.openFirewall = true
                                allowedUDPPorts = [ 443 ]; # caddy #TODO (nixpkgs 26.05) replace with services.caddy.openFirewall = true
                            };
                            hostName = "caturday";
                        };
                        nix = {
                            channel.enable = false; # disallow imperative Nix package management
                            gc = { # prevent Nix from using progressively more disk space over time
                                automatic = true;
                                dates = "06:32"; # randomly generated time of day
                                options = "--delete-old";
                            };
                            optimise = { # reduce disk space usage by hardlinking Nix store files
                                automatic = true;
                                dates = [ "19:17" ]; # randomly generated time of day
                            };
                        };
                        nixpkgs.hostPlatform = "x86_64-linux";
                        programs.zsh.enable = true; # configure Zsh integration, recommended (by https://wiki.nixos.org/wiki/Command_Shell and nixopt users.users.<name>.shell) when using Zsh as the default shell
                        security.sudo.wheelNeedsPassword = false; # allow admins to use `sudo` without having to define account passwords
                        services = {
                            caddy = {
                                enable = true; # web server reverse proxying for wurstmineberg.de and subdomains
                                email = "root@wurstmineberg.de"; # contact for Let's Encrypt
                                globalConfig = ''
                                    grace_period 10s # ensure reloads on config changes can't be delayed indefinitely by open connections
                                '';
                                virtualHosts = {
                                    "wurstmineberg.de".extraConfig = ''
                                        header Access-Control-Allow-Origin *
                                        header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload"
                                        encode
                                        handle /static/* {
                                            root /opt/git/github.com/wurstmineberg/wurstmineberg.de/main/assets
                                            file_server
                                        }
                                        reverse_proxy :24822
                                    '';
                                    "assets.wurstmineberg.de".extraConfig = ''
                                        header Access-Control-Allow-Origin *
                                        header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload"
                                        encode
                                        root /opt/git/github.com/wurstmineberg/assets.wurstmineberg.de/main
                                        file_server browse
                                    '';
                                    "caturday.wurstmineberg.de".extraConfig = ''
                                        header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload"
                                        encode
                                        redir https://wurstmineberg.de{uri}
                                    '';
                                    "graphql.wurstmineberg.de".extraConfig = ''
                                        header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload"
                                        encode
                                        reverse_proxy :24811
                                    '';
                                    "mgmt.wurstmineberg.de".extraConfig = ''
                                        header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload"
                                        encode
                                        reverse_proxy :24825
                                    '';
                                    "time.wurstmineberg.de".extraConfig = ''
                                        header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload"
                                        encode
                                        root /opt/git/github.com/wurstmineberg/time.wurstmineberg.de/main
                                        file_server
                                    '';
                                    "www.wurstmineberg.de".extraConfig = ''
                                        header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload"
                                        encode
                                        redir https://wurstmineberg.de{uri}
                                    '';
                                };
                            };
                            openssh.settings = {
                                PasswordAuthentication = false; # security
                                PermitRootLogin = lib.mkForce "no"; # security (override "prohibit-password" value from linode base image)
                            };
                        };
                        system = {
                            autoUpgrade = {
                                enable = true; # automatically keep NixOS up to date
                                allowReboot = true; # automatically reboot for kernel upgrades
                                dates = "05:32"; # randomly generated time of day
                                flags = [
                                    "--recreate-lock-file" # update all inputs
                                    "--refresh" # bypass download cache to ensure actual update
                                    "--no-write-lock-file" # required to fix “cannot write modified lock file” error
                                ];
                                flake = "github:wurstmineberg/caturday"; # update flake
                            };
                            stateVersion = "25.11"; # should NEVER be changed, see Nix option description
                            userActivationScripts.zshrc = "touch .zshrc"; # Prevent the new user dialog in Zsh
                        };
                        systemd = {
                            services.night-device-report = { # system health monitoring via Night (Fenhl's private status monitor system)
                                after = [ "network-online.target" ];
                                description = "Night device report";
                                path = with pkgs; [
                                    attrs.nixos-needsreboot.packages.${pkgs.stdenv.hostPlatform.system}.default # called during device report
                                ];
                                script = "${attrs.night-device-report.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/night-device-report";
                                serviceConfig.Type = "oneshot";
                                wants = [ "network-online.target" ];
                            };
                            timers.night-device-report = {
                                after = [ "network-online.target" ];
                                description = "Night device report timer";
                                timerConfig.OnCalendar = "*-*-* *:08:19"; # randomly generated time of the hour for the device report
                                wantedBy = [ "timers.target" ];
                                wants = [ "network-online.target" ];
                            };
                        };
                        time.timeZone = "Etc/UTC"; # disallow imperative timezone configuration
                        users = {
                            defaultUserShell = pkgs.zsh; # shell with nicer completion behavior than the default bash
                            mutableUsers = false; # disallow imperative configuration of users
                            users.fenhl = { # configure admin user accounts
                                description = "Fenhl"; # display name
                                extraGroups = [
                                    "wheel" # enable root access
                                ];
                                isNormalUser = true; # set up home directory and shell
                                openssh.authorizedKeys.keys = builtins.attrValues (builtins.mapAttrs (name: value: "${value} ${name}") (import ./authorized-keys.nix));
                            };
                        };
                    })
                ];
                specialArgs = attrs;
            };
        };
    };
}
