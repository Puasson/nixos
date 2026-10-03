{ ... }:
{
  programs.nixvim.plugins.lsp = {
    enable = true;
    inlayHints = true;
    servers = {
      pyright.enable = true;
      ruff.enable = true;
      ts_ls.enable = true;
      eslint.enable = true;
      nil_ls.enable = true;
      lua_ls = {
        enable = true;
        settings = {
          Lua = {
            diagnostics.globals = [ "vim" ];
          };
        };
      };
      qmlls.enable = true;
      html.enable = true;
      cssls.enable = true;
      tailwindcss.enable = true;
      emmet_ls.enable = true;
      jsonls.enable = true;
    };
  };
}
