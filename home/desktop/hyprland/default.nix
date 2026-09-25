{ pkgs, ... }:

{
  home.packages = with pkgs; [
    libnotify
    pavucontrol
    playerctl
    grim
    hypridle
    networkmanagerapplet
    slurp
  ];

  home.file.".config/hypr/hyprland.lua".source = ./hyprland.lua;
  home.file.".config/hypr/configs".source = ./configs;
  home.file.".config/hypr/hypridle.conf".source = ./configs/hypridle.conf;
}
