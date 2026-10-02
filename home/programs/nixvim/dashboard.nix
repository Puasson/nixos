{ lib, ... }:
let
  subaruArt = lib.splitString "\n" (builtins.readFile ../../../assets/subaru-plain.txt);
in
{
  programs.nixvim.plugins.alpha = {
    enable = true;
    settings = {
      layout = [
        {
          type = "padding";
          val = 2;
        }
        {
          type = "text";
          val = subaruArt;
          opts = {
            hl = "String";
            position = "center";
          };
        }
        {
          type = "padding";
          val = 1;
        }
        {
          type = "text";
          val = [ "S U B A R U" ];
          opts = {
            hl = "Title";
            position = "center";
          };
        }
        {
          type = "padding";
          val = 1;
        }
        {
          type = "group";
          val = [
            {
              type = "button";
              val = "n  New file";
              on_press.__raw = "function() vim.cmd('ene | startinsert') end";
              opts = {
                shortcut = "n";
                hl = "Keyword";
                position = "center";
                cursor = 3;
                width = 30;
                align_shortcut = "left";
              };
            }
            {
              type = "button";
              val = "f  Find file";
              on_press.__raw = "function() require('telescope.builtin').find_files() end";
              opts = {
                shortcut = "f";
                hl = "Keyword";
                position = "center";
                cursor = 3;
                width = 30;
                align_shortcut = "left";
              };
            }
            {
              type = "button";
              val = "g  Grep text";
              on_press.__raw = "function() require('telescope.builtin').live_grep() end";
              opts = {
                shortcut = "g";
                hl = "Keyword";
                position = "center";
                cursor = 3;
                width = 30;
                align_shortcut = "left";
              };
            }
            {
              type = "button";
              val = "s  Reload session";
              on_press.__raw = "function() require('auto-session').restore_session() end";
              opts = {
                shortcut = "s";
                hl = "Keyword";
                position = "center";
                cursor = 3;
                width = 30;
                align_shortcut = "left";
              };
            }
            {
              type = "button";
              val = "r  Recent files";
              on_press.__raw = "function() require('telescope.builtin').oldfiles() end";
              opts = {
                shortcut = "r";
                hl = "Keyword";
                position = "center";
                cursor = 3;
                width = 30;
                align_shortcut = "left";
              };
            }
          ];
        }
        {
          type = "padding";
          val = 1;
        }
        {
          type = "text";
          val = [ "python · js · ts · nix · lua · qml · html · css" ];
          opts = {
            hl = "Comment";
            position = "center";
          };
        }
      ];
      opts = {
        noautocmd = true;
      };
    };
  };
}
