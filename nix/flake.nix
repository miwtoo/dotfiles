{
  description = "Miwtoo nix-darwin system flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs =
    inputs@{ self
    , nix-darwin
    , nixpkgs
    , nix-homebrew
    , home-manager
    , nixpkgs-unstable
    }:
    let
      configuration = { pkgs, config, ... }: {
        nixpkgs.config.allowUnfree = true;
        security.pam.enableSudoTouchIdAuth = true;

        # users.users.USER.shell = pkgs.zsh;
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages =
          [
            pkgs.git
            pkgs.neovim
            pkgs.mkalias
            pkgs.vscode
            pkgs.alacritty
            pkgs.google-chrome
            pkgs.localsend
            pkgs.spotify
            pkgs.raycast
            pkgs.maccy
            pkgs.discord
            pkgs.stats
            pkgs.stow
            # pkgs.flutter326
            pkgs.cocoapods
            pkgs.jetbrains.idea-ultimate
            # pkgs.jdk23
            pkgs.direnv
            pkgs.devbox
            pkgs.oh-my-zsh
            pkgs.slack
            pkgs.monaspace
            # pkgs.android-studio
            pkgs.aldente
            pkgs.nixpkgs-fmt
            pkgs.google-cloud-sdk

            # Docker
            pkgs.colima
            # pkgs.docker
            # pkgs.docker-compose

            pkgs.bun
            pkgs.spaceship-prompt
            pkgs.zoxide
            pkgs.fira-code
          ];

        fonts.packages = with pkgs; [
          (nerdfonts.override { fonts = [ "FiraCode" ]; })
        ];

        users.users.miwtoo = {
          name = "miwtoo";
          home = "/Users/miwtoo";
        };

        homebrew = {
          enable = true;
          brews = [
            "ollama"
            "mas"
            "thefuck"
          ];
          casks = [
            "dozer"
            "miro"
            "openvpn-connect"
            "tableplus"
            "postman"
            "unnaturalscrollwheels"
          ];
          masApps = {
            Pages = 409201541;
            Numbers = 409203825;
            Xcode = 497799835;
            Keynote = 409183694;
            Messenger = 1480068668;
            TestFlight = 899247664;
          };
          onActivation.cleanup = "zap";
        };

        system.activationScripts.applications.text =
          let
            env = pkgs.buildEnv {
              name = "system-applications";
              paths = config.environment.systemPackages;
              pathsToLink = "/Applications";
            };
          in
          pkgs.lib.mkForce ''
            # Set up applications.
            echo "setting up /Applications..." >&2
            rm -rf /Applications/Nix\ Apps
            mkdir -p /Applications/Nix\ Apps
            find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
            while read -r src; do
              app_name=$(basename "$src")
              echo "copying $src" >&2
              ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
            done
          '';

        system.defaults = {
          dock.autohide = true;
          dock.persistent-apps = [
            "${pkgs.alacritty}/Applications/Alacritty.app"
            "${pkgs.vscode}/Applications/Visual Studio Code.app"
            "${pkgs.pkgs.google-chrome}/Applications/Google Chrome.app"
            "System/Applications/Mail.app"
            "System/Applications/Calendar.app"
          ];
        };

        services.nix-daemon.enable = true;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Enable alternative shell support in nix-darwin.
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in
    {
      virtualisation.docker.enable = true;
      users.users.miwtoo.extraGroups = [ "docker" ];
      virtualisation.docker.rootless = {
        enable = true;
        setSocketVariable = true;
      };



      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Wongsakorns-MacBook-Pro
      darwinConfigurations."Wongsakorns-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = false;
              user = "miwtoo";
            };
          }
          home-manager.darwinModules.home-manager
          {
            # `home-manager` config
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.miwtoo = import ./home.nix;
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Wongsakorns-MacBook-Pro".pkgs;
    };
}
