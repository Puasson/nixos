{ ... }:
{
  programs.nixvim.plugins.auto-session = {
    enable = true;
    settings = {
      auto_save = true;
      auto_restore = false;
      auto_create = true;
      suppressed_dirs = [
        "~/"
        "~/Downloads"
        "/tmp"
      ];
    };
  };
}
