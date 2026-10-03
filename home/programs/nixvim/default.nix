{ inputs, pkgs, ... }:
{
  imports = [
    ./options.nix
    ./keymaps.nix
    ./theme.nix
    ./dashboard.nix
    ./telescope.nix
    ./filetree.nix
    ./completion.nix
    ./lsp.nix
    ./syntax.nix
    ./statusline.nix
    ./motion.nix
    ./session.nix
    ./media.nix
    ./plugins.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    nixpkgs.source = inputs.nixpkgs;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    extraPackages = with pkgs; [
      ripgrep
      fd
      bat
      imagemagick
      chafa
      fortune
      nil
      nixfmt
      stylua
      ruff
    ];
  };
}
