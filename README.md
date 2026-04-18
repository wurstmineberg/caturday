This is the configuration an documentation for `caturday`, the server that will be hosting Wurstmineberg's Minecraft servers, website, and other infrastructure in the future.

# Setup

Follow these steps to get a server that's configured as an identical copy of `caturday`.

1. On any [NixOS](https://nixos.org/) system, run `nixos-rebuild build-image --image-variant=linode --flake=github:wurstmineberg/caturday#bootstrap`
2. [Upload](https://cloud.linode.com/images/create/upload) `result/nixos-image-linode-*.img.gz` as a Linode image
3. Create a linode from the image (the “Nanode 1 GB” plan should work, see <https://wurstmineberg.de/about#hosting> for the current plan)
4. Wait for the linode to finish provisioning (ensures configuration is correct)
5. Edit the configuration to change the kernel to `GRUB2` (**not** `GRUB (Legacy)`) and disable the filesystem/boot helpers
6. Reboot the linode
7. Log into LISH as `root` with the password configured in step 3
8. `nixos-rebuild switch --recreate-lock-file --refresh --no-write-lock-file --flake=github:wurstmineberg/caturday`
9. You should now be able to access caturday via SSH (assuming your user account and SSH pubkey exist in `flake.nix`)
