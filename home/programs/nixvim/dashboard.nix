{ lib, ... }:
let
  subaruArt = lib.splitString "\n" (builtins.readFile ../../../assets/subaru-xvim.txt);
in
{
  programs.nixvim.plugins.dashboard = {
    enable = true;
    settings = {
      theme = "doom";
      config = {
        header = subaruArt;
        center = [
          {
            icon = " ";
            icon_hl = "Function";
            desc = "Find file      ";
            desc_hl = "Function";
            key = "f";
            key_hl = "Number";
            key_format = " %s";
            action = "Telescope find_files";
          }
          {
            icon = " ";
            icon_hl = "Function";
            desc = "New file       ";
            desc_hl = "Function";
            key = "n";
            key_hl = "Number";
            key_format = " %s";
            action = "ene | startinsert";
          }
          {
            icon = " ";
            icon_hl = "Function";
            desc = "Recent files   ";
            desc_hl = "Function";
            key = "r";
            key_hl = "Number";
            key_format = " %s";
            action = "Telescope oldfiles";
          }
          {
            icon = " ";
            icon_hl = "Function";
            desc = "Find text      ";
            desc_hl = "Function";
            key = "g";
            key_hl = "Number";
            key_format = " %s";
            action = "Telescope live_grep";
          }
          {
            icon = " ";
            icon_hl = "Function";
            desc = "Config         ";
            desc_hl = "Function";
            key = "c";
            key_hl = "Number";
            key_format = " %s";
            action = "e /home/sora/nixos/flake.nix";
          }
          {
            icon = " ";
            icon_hl = "Function";
            desc = "Restore Session";
            desc_hl = "Function";
            key = "s";
            key_hl = "Number";
            key_format = " %s";
            action = "lua require('auto-session').RestoreSession()";
          }
          {
            icon = " ";
            icon_hl = "Function";
            desc = "Explorer       ";
            desc_hl = "Function";
            key = "e";
            key_hl = "Number";
            key_format = " %s";
            action = "Neotree toggle";
          }
          {
            icon = " ";
            icon_hl = "Function";
            desc = "Quit           ";
            desc_hl = "Function";
            key = "q";
            key_hl = "Number";
            key_format = " %s";
            action = "qa";
          }
        ];
        footer.__raw = ''
          function()
            local handle = io.popen("fortune -s 2>/dev/null")
            local fortune = handle and handle:read("*a") or ""
            if handle then handle:close() end
            fortune = fortune:gsub("%s+$", "")
            if fortune == "" then fortune = "Steady throttle, clean lines." end
            local lines = { "", "⚡ SUBARU" }
            for line in fortune:gmatch("[^\n]+") do
              table.insert(lines, "  " .. line)
            end
            return lines
          end
        '';
      };
    };
  };

  # Header azul + footer cian como en la imagen, re-aplicados tras cada colorscheme.
  programs.nixvim.extraConfigLua = ''
    local dash_hl = vim.api.nvim_create_augroup("SubaruDashboardHl", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = dash_hl,
      callback = function()
        vim.api.nvim_set_hl(0, "DashboardHeader", { link = "Function" })
        vim.api.nvim_set_hl(0, "DashboardFooter", { link = "DiagnosticHint" })
      end,
    })
    vim.api.nvim_set_hl(0, "DashboardHeader", { link = "Function" })
    vim.api.nvim_set_hl(0, "DashboardFooter", { link = "DiagnosticHint" })
  '';
}
