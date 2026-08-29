# Contributing

This file is for whoever changes this template. The [README](README.md) is
for whoever stamps a project out of it.

## Getting set up

- **[Nix](https://nixos.org/download)**, with flakes enabled (`nix.conf`
  needs `experimental-features = nix-command flakes`, or pass
  `--extra-experimental-features 'nix-command flakes'` on every invocation —
  CI passes the same setting through `cachix/install-nix-action`'s
  `extra_nix_config`, since a fresh Nix install ships both disabled).
- **[bun](https://bun.sh)** for the tooling that isn't Nix — commitlint,
  Prettier and markdownlint. There's a `package.json`, but nothing here is
  JavaScript; it exists only so those tools resolve and stay pinned.
- **statix, deadnix and nixpkgs-fmt** are not installed globally — run
  `nix develop` (or let direnv load `flake.nix` via a `.envrc` containing
  `use flake`) to put all three on `PATH`. The pre-commit and pre-push
  hooks assume that shell.

One command installs the JS-side linters and the git hooks:

```sh
bun install
```

An uninstalled hook silently does nothing, which is worse than not having
one, so the `prepare` script runs `lefthook install` for you. You find out
at the pipeline otherwise, not at the commit.

## Everyday commands

Every one of these is what a hook or CI runs — see `lefthook.yml` and
`.github/workflows/*.yml` for exactly which.

```sh
nix build .#example       # or just `nix build`, .#default points at the same thing
nix flake check
nix fmt                    # the fixer; nixpkgs-fmt --check . stays the check
statix check .
deadnix --fail .

bun run format:check       # prettier --check, add --write to fix
bun run lint:md
```

## How it fits together

`package.nix` is the single derivation both `flake.nix` and `default.nix`
callPackage — see its own header comment before renaming anything.
`flake.nix` is the primary interface (`packages.<system>.default`,
`packages.<system>.example`, `devShells.<system>.default`, a `formatter`
for `nix fmt`); `default.nix` and `shell.nix` are the non-flake equivalents,
for anyone not on flakes yet. Delete whichever pair you don't need — see
README.md's "Which files to delete" section.

`Makefile` and `src/` are the placeholder project being packaged: a "hello
world" a real Makefile-based build compiles, just so `package.nix` has
something real to build rather than a stub. A project stamped from this
template deletes both and points `package.nix`'s `src`/build phases at its
own build system instead.

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/):
`type(scope): description`, types `feat`/`fix`/`docs`/`style`/`refactor`/
`perf`/`test`/`build`/`ci`/`chore`/`revert`. Subject under 50 characters,
lowercase, no trailing full stop. commitlint enforces the shape at
commit-msg and again in CI; the length and case rules are tighter than what
it checks, so hold to them anyway.

## Branching, review, and release

Every change goes through a pull request — nothing is pushed straight to
`main`, including the bootstrapping that built this repo. Branch protection
on `main` requires a pull request before merging.

The pull request **title** has to be a valid Conventional Commit too —
`pr-title.yml` checks it with
[`amannn/action-semantic-pull-request`](https://github.com/amannn/action-semantic-pull-request).
commitlint only ever reads commit objects otherwise, and a squash merge
defaults its commit message to the pull request title, so this is the only
check standing between a badly titled pull request and a bad message on
`main`.

Once a pull request's checks are green, squash-merge it and delete the
branch. [release-please](https://github.com/googleapis/release-please)
watches the Conventional Commits on `main` and keeps a release pull request
open with the next version and changelog entry; merging that pull request
tags the release and writes the notes — nobody picks a version by hand.
`release.yml`'s `artefacts` job then builds the package with Nix and
attaches the archive, with a signed build-provenance attestation, to the
release that pull request just created.

Dependabot opens dependency pull requests directly (there's no Renovate
equivalent of "watch, don't decide" here); `dependabot-auto-merge.yml`
arms auto-merge on the patch/minor ones once the same checks every other
pull request waits for go green. `flake.lock` is not one of the ecosystems
Dependabot watches — see README.md for keeping it current by hand.
