#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bash linode-cli

set -e

nixos-rebuild build-image --image-variant=linode --flake=.#bootstrap
linode-cli image-upload --label caturday --region fr-par result/nixos-image-linode-*.img.gz #TODO parse image ID from output to further automate bootstrap
unlink result
