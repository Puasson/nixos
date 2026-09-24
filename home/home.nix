{ pkgs, ... }:

{
  imports = [
    ./programs/kitty/kitty.nix
    ./programs/fastfetch/fastfetch.nix
    ./programs/nixvim/nixvim.nix
    ./programs/opencode/opencode.nix
    ./programs/ssh/ssh.nix
    ./programs/mpv/mpv.nix
    ./desktop/hyprland/default.nix
    ./desktop/quickshell
    ./shell/bash.nix
    ./theme/gtk.nix
  ];

  home = {
    username = "edu";
    homeDirectory = "/home/edu";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
  services.ssh-agent.enable = true;

  home.packages = with pkgs; [
    brave-origin
    # gimp
    audacity
    tauon
    cava
    # onlyoffice-desktopeditors
    img2pdf
    # obsidian
    gnome-text-editor
    # zapzap
    pinta
    papers
  ];
}
