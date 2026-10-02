{ ... }:
{
  programs.nixvim.plugins = {
    lualine = {
      enable = true;
      settings = {
        options = {
          theme = "auto";
          globalstatus = true;
          component_separators = "";
          section_separators = "";
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [ "branch" ];
          lualine_c = [
            "diagnostics"
            "filename"
          ];
          lualine_x = [
            "encoding"
            "fileformat"
            "filetype"
          ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
      };
    };
    bufferline = {
      enable = true;
      settings = {
        options = {
          mode = "buffers";
          diagnostics = "nvim_lsp";
          separator_style = "thin";
          show_close_icon = false;
          offsets = [
            {
              filetype = "neo-tree";
              text = "Explorer";
              highlight = "Directory";
              text_align = "left";
            }
            {
              filetype = "NvimTree";
              text = "Explorer";
              highlight = "Directory";
              text_align = "left";
            }
          ];
        };
      };
    };
  };
}
