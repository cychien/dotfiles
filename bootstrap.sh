#!/usr/bin/env bash
# Takes a fresh Mac from nothing to a built nix-darwin config.
# Run this once. After it finishes, use ./rebuild.sh for every later change.
#
# Two ways in, both fine:
#   curl -fsSL https://raw.githubusercontent.com/cychien/dotfiles/main/bootstrap.sh | bash
#   git clone https://github.com/cychien/dotfiles ~/.dotfiles && ~/.dotfiles/bootstrap.sh
#
# Nothing here prompts, so the curl form works with no tty.
set -euo pipefail

REPO="${DOTFILES_REPO:-https://github.com/cychien/dotfiles.git}"
TARGET="$HOME/.dotfiles"

# Do this before any sudo call: sudo resets $USER to root, so whoami has to
# run as the real interactive user first.
REAL_USER="$(whoami)"

echo "==> Step 1: Determinate Nix"
# configuration.nix sets nix.enable = false, which means Determinate owns the
# daemon. Installing Nix some other way will leave you without a managed one.
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
fi
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
# sudo resets PATH to a secure default that excludes /nix/.../bin, so a
# freshly installed `nix` would not be found under sudo even though it's on
# PATH here. Resolve the absolute path now and invoke that instead.
NIX_BIN="$(command -v nix)"

echo "==> Step 2: get this repo to ~/.dotfiles"
# home.nix resolves its mkOutOfStoreSymlink paths through ~/.dotfiles, so this
# has to exist before the first switch or the build will fail to find them.
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  # Running from a clone that already exists somewhere on disk.
  DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  if [ ! -e "$TARGET" ] || [ "$(cd "$TARGET" && pwd -P)" != "$DIR" ]; then
    ln -sfn "$DIR" "$TARGET"
    echo "    linked $TARGET -> $DIR"
  else
    echo "    $TARGET already points here, nothing to do"
  fi
else
  # Piped in through curl, so there is no local copy yet. Clone with Nix's git
  # rather than the system one: a fresh Mac has no git until you sit through
  # the Xcode Command Line Tools install, and this skips that entirely.
  if [ -e "$TARGET" ]; then
    echo "    $TARGET already exists, leaving it alone"
  else
    "$NIX_BIN" run nixpkgs#git -- clone "$REPO" "$TARGET"
  fi
  DIR="$TARGET"
fi

echo "==> Step 3: match the configured username to this machine"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"
if [ -z "$FLAKE_USER" ]; then
  echo "    Could not find the single \"user = \" line in flake.nix."
  echo "    Edit flake.nix yourself before continuing."
  exit 1
elif [ "$FLAKE_USER" != "$REAL_USER" ]; then
  sed -i '' -E "s/^([[:space:]]*user = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$DIR/flake.nix"
  echo "    flake.nix: \"$FLAKE_USER\" -> \"$REAL_USER\""
  echo "    Commit that, or undo it with: git -C \"$DIR\" checkout flake.nix"
else
  echo "    flake.nix already matches \"$REAL_USER\", nothing to do"
fi

echo "==> Step 4: first darwin-rebuild switch (pinned to nix-darwin-26.05)"
echo "    Heads up: homebrew.onActivation.cleanup = \"zap\" in configuration.nix"
echo "    uninstalls every brew and cask not listed there. On a Mac with an"
echo "    existing Homebrew setup, read that list first."
# darwin-rebuild doesn't exist yet on a fresh machine, so run it straight from
# the flake this once. After this, rebuild.sh works normally.
# This fetches the darwin-rebuild tool from the nix-darwin-26.05 release branch,
# not the exact flake.lock revision. The system config it applies is still
# pinned by this repo's flake.lock.
# "mac" is the flake host label - if you renamed it, change it in flake.nix
# and rebuild.sh too.
sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake "$TARGET#mac"
# If this still fails with "nix: command not found", open a new terminal
# (Determinate adds nix to new shells' PATH) and re-run ./bootstrap.sh.

echo "==> Done. Use ./rebuild.sh for future changes."
