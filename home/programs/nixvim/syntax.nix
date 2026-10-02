{ ... }:
{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      settings = {
        ensure_installed = [
          "python"
          "javascript"
          "typescript"
          "tsx"
          "nix"
          "lua"
          "qmljs"
          "html"
          "css"
          "json"
          "yaml"
          "markdown"
          "markdown_inline"
          "bash"
        ];
        highlight.enable = true;
        indent.enable = true;
      };
    };
    treesitter-context.enable = true;
    ts-autotag.enable = true;
    rainbow-delimiters.enable = true;
  };
}
