{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
                        environment.systemPackages = with pkgs; [
                            git # required to switch to the caturday system config
                        ];
                        imports = [
                            "${modulesPath}/virtualisation/linode-config.nix"
                        ];
                        networking.hostName = "caturday";
                        nixpkgs.hostPlatform = "x86_64-linux";
                        system.stateVersion = "25.11"; # should NEVER be changed, see Nix option description
                    })
                ];
                specialArgs = attrs;
            };
            caturday = attrs.nixpkgs.lib.nixosSystem {
                modules = [
                    ({ lib, modulesPath, pkgs, ... }: {
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
                                openssh.authorizedKeys.keys = [
                                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+uRnT+NmF1PgzXrwUDezIT2LyPs1fHPiFxkvUg6UHH/Wf+sM7aJElyef2325ASnzCWn1NlaHlUqUcRGgjCDtFURf7ziXwdGyW/7l/b0NrA0/fYWrSn6hAJ1/u8NCDXxE5uhAvXjFYCRFCQ0We+b2etFAFb78Llhi196UQh1FYyWuZgpas5MvGwi738DEOnHjhdpq3IoNFM8IMNxrId3hBj2+op1JluNbS+tIJJjxZX7/mMvfQ7sBNWumXp+lvo0YTiggnCbQw9ieBdPPLyF2pqqTLOQhM7mh80eZBokCvtqdsPwfnxvziGpZBKzIVls6gTDPh+hQsRJZkPuKkzfgj fenhl@macos.bureflux.fenhl.net"
                                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIECciKGdwlLLFNXzmv95jpbQ57cFpcuLABr927x0SWzv fenhl@intercal.fenhl.net"
                                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFuDl4KwKpKFxw+9WPMdiCAuYsPWKx3N46WSd56jERp+ fenhl@kalpa.fenhl.net"
                                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHCOtLp2Ez+JAWFLFkkmQT3K529rJ/PKYkPf2IigizM fenhl@reiwa.fenhl.net"
                                    "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBGUw0GhDBTXOZPT0/yvZmofTY8Ack1eAi2S2ofPp235GYZqfXcHOLRYtWyNHSlORgTD9nxj9pt66cxDf5eO1RK8Ahp4a0dobu+IGClY5m4oH2tz6vNTTKylVNiUTW7+KJg== fenhl@salise.fenhl.net"
                                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJhm4EtHCTfINOhzyx6NN0zS6ufr88uBVgdDrmoydYcH fenhl@nixos.september.fenhl.net"
                                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGmDjnTcz70tNtGpipwSvih1C4jD3MMDhwO8hLygC/IF fenhl@windows.september.fenhl.net"
                                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0LoxVv++WDg+zNf14t5J1fTKvrBn7aEGukUjeZbj8jhmA84LbK7ZTx0yR4TZ6U1f/dr9sov89ImLod7ZaNegWEMVA39khlDRsaafL29dY4iP1lroGj3aq0lOc7p9cLRUpTkaVLjPQNdHWwjVy5KpUBL9gXa6W0qIpAc+INZsraq8DOJHCHLCqgaGBrxDaIoA1+tn2VCMPPDb3d43sMnCNbzriy9qSfOuJU06ThYEs0Y9q2z9SjG6hOlkZk81X8YBQV0/qeLoEzP531zf9QvahbESaicfBKqGZE6m3jYZWKnZhE3k3RPOMYmIbOzCvnkobDHY+Owj6d0x2yFIiQiKOrPHLHd3YZMxzODiwKAUl1MmTbbO5GcgsGLNiuA2xXKzUepStO/sS0a1nIPCNnXffo/dgxHV7mHI9OKEQ1IIAwLDR3hVUe//ca+pyBq97I00r2aro53FlLFqmIijkSO2j+ELJrdB3XIKMYvAJce8bikU2+ySDxZFKws4rsnct898= fenhl@ubuntu.wsl.september.fenhl.net"
                                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOUOtij7ITkds5GdLmGbXKPpF6UC0+XWlY/KMW4Rd2RF fenhl@thermidor.fenhl.net"
                                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzekGAV/ReIsxzE/NcGg8wbI1CS1JuSXz+svp+tS9u1botmJ5+C3Ux/tGe/WemvkJaVpURGv1+EDvNRimul3sWae931IFmJiAAqWZCoznmzXwLsuQCqObIZFUdZ6qBA1cz3TCfYF5RoFp32M+b2Ij06riSGmqEX+p+3yWhpm64yqOHI7vE8etrnjgxgcg/bokS9+c7lnCt+IcbClGYwAHmfMrWLQTHt8v5NG9G2HSKYZvqhSnodTayuFqvIMA24lMJDF0py4y/MkvFr7UV0686mbTb/sh4y3XncsLosl46UN8gMMciTw7ygJ48j77Q45pqGVzEQdj1JTQ6yQg95gtM+7LMsZp+Kpeok0tfLlwFha/MrX1tyxztRtiuWJv57BKWuY10Q8drdbnJ1lWvcddCb0+I0smpJ20yx9kVZzd8hcrmU9Br5PXNX31eSF/yuuU1TJVsH0IIOCxjBXHPyiCpM5FQEa8FqBpwAdJsGQUSAMvCvR5HqkU8DV0EHXY6U+k= fenhl@vendredi.fenhl.net"
                                ];
                            };
                        };
                    })
                ];
                specialArgs = attrs;
            };
        };
    };
}
