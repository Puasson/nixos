{ ... }:
{
  programs.nixvim.plugins = {
    luasnip.enable = true;
    friendly-snippets.enable = true;
    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;
      settings = {
        keymap = {
          preset = "enter";
        };
        appearance = {
          nerd_font_variant = "mono";
        };
        completion = {
          documentation = {
            auto_show = true;
          };
        };
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
        };
        signature.enabled = true;
      };
    };
    # Integración MCP/AI vía opencode (ya usas home/programs/opencode).
    # Requiere plugins.snacks con input habilitado según upstream.
    opencode = {
      enable = true;
    };
    snacks = {
      enable = true;
      settings = {
        bigfile.enabled = true;
        quickfile.enabled = true;
        notifier.enabled = true;
        words.enabled = true;
      };
    };
  };
}
