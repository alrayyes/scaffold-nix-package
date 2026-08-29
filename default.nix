# For non-flake users (`nix-build`, `nix-env -f .`, or Nix with flakes never
# enabled). `pkgs` defaults so plain `nix-build` works with no arguments;
# package.nix is the same file flake.nix callPackages, so there is one
# derivation, not two that can drift apart.
#
# Delete this file (and shell.nix) if you've committed to flakes only —
# see README.md.
{ pkgs ? import <nixpkgs> { } }:

pkgs.callPackage ./package.nix { }
