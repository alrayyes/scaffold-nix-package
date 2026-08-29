# The single source of truth for the derivation. Both flake.nix and
# default.nix callPackage this file, so there is exactly one place that
# describes how the package is built.
#
# Rename `pname`, the source, the build/install phases and `meta` to
# describe the real project. Everything below is a placeholder wired up
# just enough to build and install something real, so `nix build` proves
# the plumbing before you touch it.
{ lib, stdenv }:

stdenv.mkDerivation (finalAttrs: {
  pname = "example";
  version = "0.1.0";

  src = ./.;

  # stdenv's default buildPhase already runs `make`; only installPhase needs
  # spelling out, since the Makefile's own `install` target expects PREFIX.
  installPhase = ''
    runHook preInstall
    make install PREFIX=$out
    runHook postInstall
  '';

  meta = {
    description = "Example program packaged with Nix — replace this with the real project's description";
    homepage = "https://github.com/alrayyes/scaffold-nix-package"; # replace with the real project's homepage
    # PLACEHOLDER: set this to the packaged project's actual license.
    # See lib.licenses in nixpkgs for the full list of recognized SPDX ids.
    license = lib.licenses.mit;
    maintainers = [
      {
        name = "Your Name";
        email = "you@example.com";
        github = "your-github-handle";
        githubId = 0; # replace with your numeric GitHub user id (`gh api user --jq .id`)
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = finalAttrs.pname;
  };
})
