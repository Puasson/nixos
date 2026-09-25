{ ... }:

{
  programs.nixvim.plugins.dashboard = {
    enable = true;
    settings = {
      theme = "hyper";
      config = {
        header = [
          ""
          "  ███████╗██╗   ██╗██████╗  █████╗ ██████╗ ██╗   ██╗"
          "  ██╔════╝██║   ██║██╔══██╗██╔══██╗██╔══██╗██║   ██║"
          "  ███████╗██║   ██║██████╔╝███████║██████╔╝██║   ██║"
          "  ╚════██║██║   ██║██╔══██╗██╔══██║██╔══██╗██║   ██║"
          "  ███████║╚██████╔╝██████╔╝██║  ██║██║  ██║╚██████╔╝"
          "  ╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝"
          ""
        ];
        week_header.enable = false;
        shortcut = [
          {
            icon = " ";
            icon_hl = "@variable";
            desc = "Find File";
            group = "DiagnosticHint";
            action = "Telescope find_files";
            key = "f";
          }
          {
            icon = " ";
            icon_hl = "@variable";
            desc = "New File";
            group = "DiagnosticHint";
            action = "enew";
            key = "n";
          }
          {
            icon = " ";
            icon_hl = "@variable";
            desc = "Projects";
            group = "DiagnosticHint";
            action = "Telescope find_files cwd=$HOME/nixos";
            key = "p";
          }
          {
            icon = " ";
            icon_hl = "@variable";
            desc = "Find Text";
            group = "DiagnosticHint";
            action = "Telescope live_grep";
            key = "g";
          }
          {
            icon = " ";
            icon_hl = "@variable";
            desc = "Recent Files";
            group = "DiagnosticHint";
            action = "Telescope oldfiles";
            key = "r";
          }
          {
            icon = " ";
            icon_hl = "@variable";
            desc = "Config";
            group = "DiagnosticHint";
            action = "edit $HOME/nixos/home/programs/nixvim/nixvim.nix";
            key = "c";
          }
          {
            icon = " ";
            icon_hl = "@variable";
            desc = "Restore Session";
            group = "DiagnosticHint";
            action = "lua require('persistence').load()";
            key = "s";
          }
          {
            icon = " ";
            icon_hl = "@variable";
            desc = "Lazy Extras";
            group = "DiagnosticHint";
            action = "LazyGit";
            key = "x";
          }
          {
            icon = "󰒲 ";
            icon_hl = "@variable";
            desc = "Lazy";
            group = "DiagnosticHint";
            action = "checkhealth";
            key = "l";
          }
          {
            icon = " ";
            icon_hl = "@variable";
            desc = "Quit";
            group = "DiagnosticHint";
            action = "qa";
            key = "q";
          }
        ];
        footer.__raw = "{ '', '  Neovim v' .. tostring(vim.version()) .. ' ', }";
        mru.limit = 0;
        project.enable = false;
      };
    };
  };
}
