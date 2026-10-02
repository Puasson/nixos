{ pkgs, ... }:

{
  imports = [
    ./programs/kitty/kitty.nix
    ./programs/fastfetch/fastfetch.nix
    ./programs/nixvim/default.nix
    ./programs/opencode/opencode.nix
    ./programs/ssh/ssh.nix
    ./programs/mpv/mpv.nix
    ./programs/obs/obs.nix
    ./programs/wayscriber/default.nix
    ./programs/python/python.nix
    ./desktop/hyprland/default.nix
    ./desktop/quickshell
    ./shell/bash.nix
    ./theme/gtk.nix
  ];

  home = {
    username = "sora";
    homeDirectory = "/home/sora";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
  services.ssh-agent.enable = true;

  home.packages = with pkgs; [
    brave-origin
    gimp
    audacity
    tauon
    cava
    img2pdf
    obsidian
    gnome-text-editor
    pinta
    papers
    karere
    onlyoffice-desktopeditors
    qbittorrent
    inkscape
    drawio
    spotify
    zed-editor
    gnome-calculator
    morgen
    thunderbird
    telegram-desktop
    keepassxc
  ];
}
