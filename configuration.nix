{ user, ... }:

{
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };

  system.stateVersion = 6;
  security.pam.services.sudo_local.touchIdAuth = true;
  system.defaults = {
    NSGlobalDomain = {
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock = {
      autohide = true;
      show-recents = false;
      persistent-apps = [
        "/Applications/Ghostty.app"
        "/Applications/Google Chrome.app"
        "/Applications/Slack.app"
        "/Applications/Notion.app"
        "/Applications/Todoist.app"
        "/Applications/Figma.app"
      ];
    };
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad = {
      Clicking = true;           # tap to click
      TrackpadRightClick = true; # two-finger tap for secondary click
      # three fingers drag windows and select text, so the swipes move to four
      TrackpadThreeFingerDrag = true;
      TrackpadThreeFingerVertSwipeGesture = 0;
      TrackpadThreeFingerHorizSwipeGesture = 0;
      TrackpadFourFingerVertSwipeGesture = 2;   # mission control, app expose
      TrackpadFourFingerHorizSwipeGesture = 2;  # switch full-screen apps
    };
    WindowManager.StandardHideWidgets = true;  # no widgets on the desktop
  };
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "herdr"
    ];
    casks = [
      "ghostty"
      "claude-code"
      "figma"
      "google-chrome"
      "notion"
      "opensuperwhisper"
      "raycast"
      "slack"
      "todoist-app"
    ];
  };
}
