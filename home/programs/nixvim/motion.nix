{ ... }:
{
  programs.nixvim.plugins.flash = {
    enable = true;
    settings = {
      modes = {
        char.enabled = true;
        search.enabled = true;
      };
    };
  };
}
