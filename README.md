# dotfiles

macOS setup as one nix-darwin flake: system defaults, Homebrew casks, and
home-manager (zsh, starship, neovim, cli tools, agent instruction files).

## Setting up a new Mac

Open Terminal, paste this line, press Enter:

```sh
curl -fsSL https://raw.githubusercontent.com/cychien/dotfiles/main/bootstrap.sh | bash
```

Here's what happens:

1. Text starts scrolling by (Nix is installing)
2. It stops and asks for **your Mac login password**. You won't see the
   characters as you type - that's normal. Press Enter when done
3. More text scrolls by (downloading the config, installing apps)
4. It asks for the password a second time
5. It keeps going. This is the long part - roughly 5 to 15 minutes depending on
   your connection
6. It prints `==> Done.`

You never have to answer a question. Paste one line, type your password twice,
wait.

When it finishes, close Terminal and open a new one. You'll get a new prompt
style, grey autocomplete suggestions as you type, and `nvim`, `rg`, `fzf` and
friends on your PATH. Ghostty, Claude Code, Chrome, Raycast and Slack are
installed too.

A few things about your Mac will also change: the menu bar and the Dock hide
themselves, desktop icons and widgets are gone, the trackpad taps to click and
two-finger taps for right click, and three fingers drag instead of swiping -
Mission Control and full-screen switching move to four fingers. Those are
deliberate settings, not breakage.

**If you're not cychien:** this installs someone else's config. To make it your
own, fork this repo on GitHub, then run the command again with your username in
place of `cychien`. See [Making it yours](#making-it-yours) for what to edit.

## Every change after that

```sh
./rebuild.sh
```

## What the one-liner actually does

Installs Determinate Nix, clones this repo to `~/.dotfiles`, rewrites the single
`user = "…"` line in `flake.nix` to match whoever runs it, and runs the first
`darwin-rebuild switch`. It never prompts. You do not need Xcode Command Line
Tools first - the clone uses Nix's own git.

If you'd rather keep the repo somewhere else, clone it yourself and run the
script from there; it symlinks whatever directory it lives in to `~/.dotfiles`,
which is where `home.nix` looks for the files it links out of the store.

## Making it yours

`bootstrap.sh` handles the macOS username for you. Everything else in here is
personal and worth a look before or after your first switch:

- `home/AGENTS.md` - coding agent instructions, symlinked to four paths
- `home/.agents/skills/` - global agent skills, installed with `npx skills add -g`
- `home/.config/herdr/` - herdr's config
- `home.nix` - shell aliases, packages, prompt
- `configuration.nix` - Homebrew casks, macOS defaults

## Running this on a Mac that's already set up

The one-liner assumes a fresh machine. On a Mac you've been using, read these
first:

- `configuration.nix` sets `homebrew.onActivation.cleanup = "zap"`, which
  **uninstalls every brew and cask not listed in that file**.
- `nix-homebrew.autoMigrate = true` takes over an existing Homebrew install.
- `home.nix` sets no `home.backupFileExtension`, so an existing `~/.zshrc`,
  `~/AGENTS.md`, or `~/.claude/CLAUDE.md` will abort the switch rather than
  being backed up.

## Layout

| file | what's in it |
| --- | --- |
| `flake.nix` | inputs, pinned to the 26.05 release branches; the `user` line |
| `configuration.nix` | system defaults, Homebrew brews and casks |
| `home.nix` | packages, zsh, starship, dotfile symlinks |
| `home/` | the actual dotfiles, symlinked out of the store so edits are live |
| `CLAUDE.md` | points Claude at `home/AGENTS.md`; edit that, not this |

## Credits

Inspired by [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles).
