{ ... }:
{
  programs.nixvim.plugins.telescope = {
    enable = true;
    extensions = {
      fzf-native.enable = true;
      ui-select.enable = true;
    };
    settings = {
      defaults = {
        prompt_prefix = " ";
        selection_caret = " ";
        file_ignore_patterns = [
          "^.git/"
          "node_modules/"
          "__pycache__/"
          "%.lock"
        ];
        layout_config = {
          horizontal = {
            preview_width = 0.55;
          };
        };
      };
      pickers = {
        find_files = {
          hidden = true;
        };
      };
    };
    # Keymaps centralizados en keymaps.nix (estilo LazyVim).
    # Se deja vacío para evitar doble registro.
    keymaps = { };
  };
}
