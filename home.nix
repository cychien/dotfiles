{ config, lib, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  linkDotfile = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";

  # each agent looks for its global instructions at a different path
  agentGuidelinePaths = [
    "AGENTS.md"
    ".claude/CLAUDE.md"
    ".codex/AGENTS.md"
    ".config/opencode/AGENTS.md"
  ];

  # coding agents ship updates daily, so they come from their own installers
  # rather than nixpkgs; both land in ~/.local/bin.
  # the installers expect a normal macOS shell - home-manager's activation PATH
  # has no curl or tar, and they rewrite a shell rc if the target is off PATH
  officialInstall = name: url: lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -x "$HOME/.local/bin/${name}" ]; then
      run env PATH="$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
        /bin/bash -c "curl -fsSL ${url} | bash" \
        || echo "${name}: install failed, run: curl -fsSL ${url} | bash"
    fi
  '';
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    gh        # github cli, also handles push auth
    neovim
    nodejs    # lsp servers and formatters that ship as npm packages
    pnpm
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude";
      co = "codex --approve-for-me";
    };
  };

  programs.fzf.enable = true;  # ctrl+r history search, ctrl+t file picker

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "cychien";
      user.email = "xyz030206@gmail.com";
      # macOS git still defaults to master
      init.defaultBranch = "main";
    };
  };

  # lazy.nvim owns plugin installs, so rebuild drives it from the committed lockfile
  home.activation.lazyvim = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    PATH="${lib.makeBinPath [ pkgs.git ]}:$PATH"
    nvim=${pkgs.neovim}/bin/nvim
    masonBin="$HOME/.local/share/nvim/mason/bin"

    run $nvim --headless "+Lazy! restore" +qa \
      || echo "nvim: lazy.nvim restore failed, run :Lazy restore inside nvim"

    # nvim-treesitter needs the tree-sitter CLI; mason is not driven by the lockfile
    if [ ! -x "$masonBin/tree-sitter" ] \
      || [ ! -x "$masonBin/stylua" ] \
      || [ ! -x "$masonBin/shfmt" ]; then
      run $nvim --headless \
        -c "Lazy! load mason.nvim" \
        -c "MasonInstall tree-sitter-cli stylua shfmt" -c qa \
        || echo "nvim: mason install failed, run :Mason inside nvim"
    fi
  '';

  home.activation.claudeCode = officialInstall "claude" "https://claude.ai/install.sh";
  home.activation.codex = officialInstall "codex" "https://chatgpt.com/codex/install.sh";

  home.file = {
    # gitignored files fd/rg should still surface (so nvim pickers see them)
    ".ignore".source = linkDotfile "home/.ignore";
    ".config/herdr".source = linkDotfile "home/.config/herdr";
    ".config/nvim".source = linkDotfile "home/.config/nvim";
    ".config/ghostty".source = linkDotfile "home/.config/ghostty";
    ".claude/settings.json".source = linkDotfile "home/.claude/settings.json";
    ".claude/skills".source = linkDotfile "home/.claude/skills";
    # `npx skills` keeps its global install lockfile here
    ".agents".source = linkDotfile "home/.agents";
  } // lib.genAttrs agentGuidelinePaths (_: {
    source = linkDotfile "home/AGENTS.md";
  });
}
