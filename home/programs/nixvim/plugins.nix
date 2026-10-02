{ ... }:
{
  programs.nixvim.plugins = {
    which-key.enable = true;
    gitsigns.enable = true;
    todo-comments.enable = true;
    trouble.enable = true;
    comment.enable = true;
    nvim-autopairs.enable = true;
    conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
        formatters_by_ft = {
          python = [ "ruff_format" ];
          javascript = [ "prettierd" ];
          typescript = [ "prettierd" ];
          javascriptreact = [ "prettierd" ];
          typescriptreact = [ "prettierd" ];
          nix = [ "nixfmt" ];
          lua = [ "stylua" ];
          html = [ "prettierd" ];
          css = [ "prettierd" ];
          json = [ "prettierd" ];
          qml = [ "qmlls" ];
        };
      };
    };
    lint = {
      enable = true;
      lintersByFt = {
        python = [ "ruff" ];
        javascript = [ "eslint" ];
        typescript = [ "eslint" ];
        nix = [ "nix" ];
      };
    };
  };
}
