{ inputs, pkgs, ... }:

{
  imports = [
    ./dashboard.nix
    ./keymaps.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    nixpkgs.source = inputs.nixpkgs;

    extraConfigLuaPre = ''
      do
        local f = io.open(os.getenv("HOME") .. "/.cache/quickshell/theme/mode", "r")
        local m = f and f:read("*l") or nil
        if f then f:close() end
        vim.o.background = (m == "light") and "light" or "dark"
      end
      vim.cmd("colorscheme catppuccin")
    '';

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      termguicolors = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      updatetime = 250;
      timeoutlen = 300;
      clipboard = "unnamedplus";
      undofile = true;
      ignorecase = true;
      smartcase = true;
      splitbelow = true;
      splitright = true;
      wrap = false;
      swapfile = false;
    };

    globals.mapleader = " ";

    diagnostic.settings = {
      virtual_text = true;
      signs = true;
      underline = true;
      update_in_insert = false;
      severity_sort = true;
    };

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "auto";
        background = {
          light = "latte";
          dark = "mocha";
        };
        transparent_background = true;
        float = {
          transparent = true;
          solid = false;
        };
        integrations = {
          cmp = true;
          gitsigns = true;
          treesitter = true;
          telescope.enabled = true;
          indent_blankline.enabled = true;
          native_lsp = {
            enabled = true;
            underlines = {
              errors = [ "undercurl" ];
              hints = [ "undercurl" ];
              warnings = [ "undercurl" ];
              information = [ "undercurl" ];
            };
          };
          neotree.enabled = true;
          which_key = true;
        };
      };
    };

    plugins = {
      web-devicons.enable = true;
      neo-tree.enable = true;
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
        settings.defaults = {
          file_ignore_patterns = [
            "^%.git/"
            "node_modules"
            "%.lock$"
          ];
        };
      };
      treesitter = {
        enable = true;
        highlight.enable = true;
        indent.enable = true;
        folding.enable = false;
      };
      lualine.enable = true;
      which-key.enable = true;
      bufferline.enable = true;
      gitsigns.enable = true;
      indent-blankline.enable = true;
      illuminate.enable = true;
      flash.enable = true;
      trouble.enable = true;
      lazygit.enable = true;
      nvim-autopairs.enable = true;
      comment.enable = true;
      ts-context-commentstring.enable = true;
      nvim-surround.enable = true;
      todo-comments.enable = true;
      persistence.enable = true;
      friendly-snippets.enable = true;

      ccc = {
        enable = true;
        settings = {
          highlight_mode = "background";
          highlighter = {
            auto_enable = true;
            lsp = true;
          };
        };
      };

      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          nixd = {
            enable = true;
            settings = {
              formatting.command = [ "nixfmt" ];
              nixpkgs.expr = "import <nixpkgs> { }";
            };
          };
          lua_ls.enable = true;
          ts_ls.enable = true;
          bashls.enable = true;
          jsonls.enable = true;
          yamlls.enable = true;
          pylsp = {
            enable = true;
            settings.plugins.ruff.enabled = true;
          };
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            lua = [ "stylua" ];
            python = [
              "ruff_organize_imports"
              "ruff_format"
            ];
            javascript = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "prettier";
              stop_after_first = true;
            };
            typescript = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "prettier";
              stop_after_first = true;
            };
            javascriptreact = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "prettier";
              stop_after_first = true;
            };
            typescriptreact = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "prettier";
              stop_after_first = true;
            };
            json = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "prettier";
              stop_after_first = true;
            };
            yaml = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "prettier";
              stop_after_first = true;
            };
            css = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "prettier";
              stop_after_first = true;
            };
            markdown = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "prettier";
              stop_after_first = true;
            };
            nix = [ "nixfmt" ];
            "_" = [ "trim_whitespace" ];
          };
          format_on_save = {
            lsp_format = "fallback";
            timeout_ms = 500;
          };
        };
      };

      lint = {
        enable = true;
        lintersByFt = {
          python = [
            "ruff"
            "mypy"
          ];
        };
      };

      cmp = {
        enable = true;
        settings = {
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
          mapping = {
            "<CR>".__raw = "cmp.mapping.confirm({ select = true })";
            "<Tab>".__raw = "cmp.mapping.select_next_item()";
            "<S-Tab>".__raw = "cmp.mapping.select_prev_item()";
            "<C-Space>".__raw = "cmp.mapping.complete()";
            "<C-e>".__raw = "cmp.mapping.abort()";
          };
        };
        cmdline = {
          "/" = {
            mapping.__raw = "cmp.mapping.preset.cmdline()";
            sources = [ { name = "buffer"; } ];
          };
          ":" = {
            mapping.__raw = "cmp.mapping.preset.cmdline()";
            sources = [
              { name = "path"; }
              { name = "cmdline"; }
            ];
          };
        };
      };

      luasnip = {
        enable = true;
        fromVscode = [ { } ];
      };
      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp-cmdline.enable = true;
    };

    extraPackages = with pkgs; [
      ripgrep
      fd
      gcc
      stylua
      ruff
      mypy
      prettierd
      prettier
      nixfmt
      lazygit
      bash-language-server
      vscode-langservers-extracted
      yaml-language-server
    ];
  };
}
