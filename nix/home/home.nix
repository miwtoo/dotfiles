{ config
, pkgs
, meta
, lib
, ...
}:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  programs.home-manager.enable = true;

  programs.direnv.enable = true;

  home.stateVersion = "24.05";

  programs = {
    zsh = import ./zsh.nix { inherit config pkgs lib; };
    zoxide = import ./zoxide.nix { inherit config pkgs; };
    starship = import ./starship.nix { inherit config pkgs meta; };
  };
}
