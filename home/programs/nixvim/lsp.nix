{ ... }:
{
  programs.nixvim.plugins.lsp = {
    enable = true;
    inlayHints = true;
    servers = {
      # Python
      pyright.enable = true;
      ruff.enable = true;
      # JavaScript / TypeScript
      ts_ls.enable = true;
      eslint.enable = true;
      # Nix
      nil_ls.enable = true;
      # Lua
      lua_ls = {
        enable = true;
        settings = {
          Lua = {
            diagnostics.globals = [ "vim" ];
          };
        };
      };
      # QML (qtdeclarative). Si el binario no está en PATH, queda como
      # cliente LSP pasivo; treesitter/highlight lo cubren.
      qmlls.enable = true;
      # HTML / CSS / JSON
      html.enable = true;
      cssls.enable = true;
      tailwindcss.enable = true;
      emmet_ls.enable = true;
      jsonls.enable = true;
    };
  };
}
