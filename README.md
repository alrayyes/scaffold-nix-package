# scaffold-nix-package

A [GitHub template repository](https://github.com/alrayyes/scaffold-nix-package)
for packaging any project as a Nix derivation. It's the GitHub-native sibling
of a template repo of the same name on
[git.higherlearning.eu](https://git.higherlearning.eu/alrayyes/scaffold-nix-package)
— same idea, GitHub-native tooling (Actions, Dependabot, release-please)
instead of Forgejo's.

Use the green **Use this template** button (or
`gh repo create <name> --template alrayyes/scaffold-nix-package`) rather than
forking or cloning directly — that starts a new repo with this history
squashed into one initial commit, not one that tracks this template's own.

## What's actually here

A real, buildable Nix package, not a stub:

- **`flake.nix`** — the primary interface. `packages.<system>.default` and
  `packages.<system>.example` (the same derivation under two names, so both
  `nix build` and `nix build .#example` work), `devShells.<system>.default`,
  and a `formatter` output so `nix fmt` works. Supports `x86_64-linux` and
  `aarch64-linux`, via [flake-utils](https://github.com/numtide/flake-utils)
  rather than hand-rolled per-system boilerplate — `flake-utils.lib.eachSystem`
  is a small, widely used dependency that does exactly that `system:` closure
  and nothing else, and it's already this template's `flake.lock`, so there's
  no extra input to weigh against hand-rolling it.
- **`package.nix`** — the derivation itself
  (`stdenv.mkDerivation`), with a real `meta` attrset. Both `flake.nix` and
  `default.nix` callPackage this one file, so there's a single source of
  truth for what gets built.
- **`default.nix`** and **`shell.nix`** — the non-flake equivalents, for
  `nix-build`, `nix-env -f .`, and `nix-shell`. See "Which files to delete"
  below.
- **`Makefile`** and **`src/main.c`** — a placeholder "hello world" that
  `package.nix` actually builds, so `nix build` proves the packaging works
  end to end rather than evaluating a derivation with nothing behind it.

## Adapting this template

1. **Rename the package.** In `package.nix`, change `pname` (and, if it's
   not staying at `0.1.0`, `version`) from `example` to the real name. Update
   the matching attribute names in `flake.nix`'s `packages` set
   (`packages.<system>.example` → `packages.<system>.<your-name>`) and
   `meta.mainProgram` if the built binary's name changes too.
2. **Point it at a real build.** Delete `Makefile` and `src/`, and replace
   `package.nix`'s `src`, `installPhase` (and `buildPhase`/`nativeBuildInputs`
   if the default `make`-based `buildPhase` doesn't fit) with whatever
   actually builds the real project — a language-specific `stdenv.mkDerivation`
   wrapper (`buildGoModule`, `rustPlatform.buildRustPackage`, `python3.pkgs.buildPythonApplication`,
   …) probably fits better than raw `stdenv.mkDerivation` once there's a real
   toolchain involved; swap it in there.
3. **Fill in `meta`.** `description`, `homepage`, `license` (a real SPDX id
   from `lib.licenses` — matching whatever you put in `LICENSE`, not the
   placeholder that's there now), `maintainers` (your own
   name/email/GitHub handle/numeric GitHub id — `gh api user --jq .id`), and
   `platforms` if the real project doesn't run everywhere this template
   claims.
4. **Update this README** — the sections above describe the template, not
   whatever gets built from it. Replace them; keep "Publishing a Nix
   package" below, since it's the one part that stays true for any Nix
   package.

### Which files to delete

This template ships both a flake and the classic non-flake interface so it
works either way out of the box. Real projects usually commit to one:

- **Flakes only**: delete `default.nix` and `shell.nix`. `flake.nix` and
  `package.nix` are all a flakes-only consumer needs.
- **No flakes** (`nix-build`/`nix-shell`, or supporting users on Nix without
  flakes enabled): delete `flake.nix`. `default.nix`, `shell.nix` and
  `package.nix` still work together exactly as before — `default.nix`
  already just `callPackage`s `package.nix`, the same thing `flake.nix` did.

Keeping both costs nothing but the small `package.nix` split, so it's the
default here; delete once you know your users.

## Building and checking locally

```sh
nix build              # or `nix build .#example` — same derivation, either name
nix flake check         # evaluates every output for your system; also runs in CI
nix develop              # drops into devShells.default: statix, deadnix, nixpkgs-fmt on PATH

# without flakes:
nix-build
nix-shell
```

`flake.lock` is committed and pins `nixpkgs` and `flake-utils` to exact
revisions — the same discipline this house applies to every other
dependency. Nothing watches it automatically: there's no Dependabot (or
Renovate) ecosystem for flake inputs, so update it by hand periodically:

```sh
nix flake update
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the linters, the git hooks, and
how CI is put together.

## Publishing a Nix package

Nix's own distribution model makes "publishing" mostly optional, and where
it isn't, the barrier is lower than most package ecosystems'. Three options,
roughly in order of how far the package needs to reach:

### Nothing, if a GitHub URL is enough

Flakes make a public repo itself the distribution point — no registry, no
publish step:

```sh
nix profile install github:alrayyes/scaffold-nix-package
nix build github:alrayyes/scaffold-nix-package#example
```

Or as a flake input in someone else's `flake.nix`:

```nix
inputs.example.url = "github:alrayyes/scaffold-nix-package";
```

Anyone with Nix and network access already has everything they need. This is
enough for personal tools, internal packages, or anything whose users are
already comfortable with flake URLs.

### NUR — the low-barrier option

The [Nix User Repository](https://github.com/nix-community/NUR) is a
community-run aggregator of self-hosted package expressions: your repo stays
yours (this one, or wherever `package.nix` lives), and you register it with
a small pull request against NUR's own manifest
([`repos.json`](https://github.com/nix-community/NUR/blob/main/repos.json))
pointing at it. NUR periodically re-evaluates every registered repo and
publishes the result as `pkgs.nur.repos.<your-username>.<package>` for
anyone who opts into the NUR overlay. No sponsorship, no nixpkgs-review
process, no maintainer signing off on the package itself — just a pointer
they check is well-formed. This is the middle ground: more discoverable
than a bare GitHub URL, without nixpkgs' review bar.

### nixpkgs — the reach-everyone option

Getting a package into [`NixOS/nixpkgs`](https://github.com/NixOS/nixpkgs)
itself puts it in front of every NixOS and Nix user by default, with no
extra input or overlay needed. The process:

1. Fork `nixpkgs`, add the package expression — new packages generally go
   under `pkgs/by-name/<first-two-letters-of-pname>/<pname>/package.nix`,
   nixpkgs' current convention for straightforward packages (verify against
   `pkgs/by-name/README.md` in whatever nixpkgs revision you're targeting —
   the exact structure has moved before and could again).
2. Open a pull request against `nixpkgs`. It goes through nixpkgs' normal
   review: automated checks (does it build, does `nixpkgs-review` pass on
   the affected platforms), then a human reviewer — often, though not
   always, one of the package's listed `meta.maintainers`.
3. A nixpkgs maintainer merges it once satisfied. There's no formal
   sponsorship gate the way some distributions require (Debian's
   new-maintainer process, for instance) — review quality and maintainer
   bandwidth are the real gate, not a membership requirement.

This is the highest-effort path and the only one that isn't fully within
your own control (a maintainer has to actually merge it), but it's also the
one that needs no separate infrastructure from you afterward — nixpkgs'
own release process carries the package from there.
