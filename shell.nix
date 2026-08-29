# nix-shell's equivalent of flake.nix's devShells.default, for anyone not
# using flakes. Delete this (and default.nix) if you've committed to flakes
# only — see README.md.
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  inputsFrom = [ (pkgs.callPackage ./package.nix { }) ];
  packages = with pkgs; [
    nixpkgs-fmt
    statix
    deadnix
  ];
}
