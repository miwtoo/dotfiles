{ config
, pkgs
, lib
, ...
}:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  programs.home-manager.enable = true;

  programs.starship.enable = true;
  programs.direnv.enable = true;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  home.stateVersion = "24.05";

  programs = {
    zsh = import ./home/zsh.nix { inherit config pkgs lib; };
  };
}
