{ ... }:
{
  programs.nixvim.plugins = {
    mini-icons = {
      enable = true;
      mockDevIcons = true;
    };
    web-devicons.enable = true;
    neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        window = {
          width = 30;
        };
        filesystem = {
          follow_current_file.enabled = true;
          hijack_netrw_behavior = "open_current";
          use_libuv_file_watcher = true;
        };
      };
    };
  };
}
