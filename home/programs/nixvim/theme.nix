{ ... }:
{
  # y nvim-flavour (mocha/latte). Catppuccin es el único colorscheme que
  # usa exactamente esos flavours, con background auto.
  programs.nixvim = {
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "auto";
        background = {
          light = "latte";
          dark = "mocha";
        };
        transparent_background = true;
        term_colors = true;
        integrations = {
          alpha = true;
          cmp = true;
          gitsigns = true;
          mini = true;
          native_lsp = {
            enabled = true;
            underlines = {
              errors = [ "undercurl" ];
              hints = [ "undercurl" ];
              warnings = [ "undercurl" ];
              information = [ "undercurl" ];
            };
          };
          neotree = true;
          telescope.enabled = true;
          treesitter = true;
          which_key = true;
          lualine = true;
          bufferline = true;
        };
      };
    };

    # Sincroniza background de Neovim con el sistema al arrancar.
    extraConfigLua = ''
      local function apply_system_theme()
        local bg_file = vim.fn.expand("~/.cache/quickshell/theme/nvim-background")
        local f = io.open(bg_file, "r")
        if f then
          local bg = f:read("*l") or ""
          f:close()
          bg = bg:gsub("%s+", "")
          if bg == "light" or bg == "dark" then
            vim.o.background = bg
          end
        end
      end
      apply_system_theme()
      vim.api.nvim_create_autocmd("Signal", {
        pattern = "SIGUSR1",
        callback = function()
          apply_system_theme()
          vim.cmd("colorscheme catppuccin")
        end,
      })
    '';
  };
}
