{ pkgs, ... }:
{
  programs.nixvim.plugins = {
    image = {
      enable = true;
      settings = {
        backend = "kitty";
        integrations = {
          markdown.enabled = true;
          html.enabled = true;
          css.enabled = true;
        };
        max_width = 100;
        max_height = 12;
        hijack_file_patterns = [
          "*.png"
          "*.jpg"
          "*.jpeg"
          "*.gif"
          "*.webp"
          "*.avif"
        ];
      };
    };
    colorizer = {
      enable = true;
      settings = {
        user_default_options = {
          names = true;
          RGB = true;
          RRGGBB = true;
          rgb_fn = true;
          hsl_fn = true;
          css = true;
          tailwind = true;
        };
      };
    };
  };

  home.packages = with pkgs; [
    ueberzugpp
  ];
}
