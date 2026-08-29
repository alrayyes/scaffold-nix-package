{
  description = "Template for packaging a project as a Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    # flake-utils over hand-rolled per-system boilerplate: the alternative is
    # a `builtins.listToAttrs (map (system: ...) systems)` for every one of
    # packages/devShells/etc, and flake-utils is a small, widely used
    # dependency that does exactly that and nothing else.
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        example = pkgs.callPackage ./package.nix { };
      in
      {
        packages = {
          default = example;
          inherit example;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ example ];
          packages = with pkgs; [
            nixpkgs-fmt
            statix
            deadnix
          ];
        };

        # So `nix fmt` reformats the same way the pre-commit hook and CI
        # check it — one formatter, named once.
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
