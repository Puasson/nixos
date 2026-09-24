{ pkgs, ... }:
let
  sddm-catppuccin = pkgs.catppuccin-sddm.override {
    flavor = "mocha";
    accent = "mauve";
    font = "Ubuntu Sans";
    fontSize = "11";
  };
in

{
  environment.systemPackages = [ sddm-catppuccin ];

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-mocha-mauve";
      package = pkgs.kdePackages.sddm;
      extraPackages = with pkgs; [
        qt6.qtmultimedia
        qt6.qtsvg
        qt6.qtvirtualkeyboard
      ];
    };
    defaultSession = "hyprland-uwsm";
    autoLogin.enable = false;
  };
}
