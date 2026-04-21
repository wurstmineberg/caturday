This is the configuration an documentation for `caturday`, the server that will be hosting Wurstmineberg's Minecraft servers, website, and other infrastructure in the future.

# Setup

Follow these steps to get a server that's configured as an identical copy of `caturday`. You will need a backup of the database, which can be created using `sudo -u postgres pg_dump -Cc --if-exists wurstmineberg > backup.sql`.

1. On any [NixOS](https://nixos.org/) system, run `assets/bootstrap.sh` from a clone of this repo
2. Create a linode from the `caturday` image (the “Nanode 1 GB” plan should work, see <https://wurstmineberg.de/about#hosting> for the current plan)
3. Wait for the linode to finish provisioning (ensures configuration is correct)
4. Delete the image to stop it from continuing to accrue charges
5. Power off the linode
6. On the Storage tab, increase swap to 1024 MB
7. On the Configurations tab, edit the default configuration:
    * Change the kernel to `GRUB2` (**not** `GRUB (Legacy)`)
    * Disable the filesystem/boot helpers
8. Power on the linode
9. Wait until the linode has finished switching to the full system config. You can open LISH to monitor the progress.
10. You can now access the linode via SSH (assuming your user account and SSH pubkey exist in `flake.nix` in this repo). You can open LISH to view the host key fingerprint.
11. Restore the database from your backup (`cat backup.sql | sudo -u postgres psql -q`)

# Adding new secrets

1. Make sure you have an `ssh-ed25519` pubkey in `assets/authorized-keys.nix`
2. Edit `secrets.nix` to add the filename (e.g. `foo.age`) to the list marked with the comment
3. `nix run github:ryantm/agenix -- -e secrets/foo.age`
4. Undo the change to `secrets.nix`

# Editing existing secrets

1. Make sure you have an `ssh-ed25519` pubkey in `assets/authorized-keys.nix`
2. Make sure an existing admin has run `nix run github:ryantm/agenix -- -r` since your key was added
3. `nix run github:ryantm/agenix -- -e secrets/foo.age`
