{ pkgs, lib, ... }:

{
  programs.opencode = {
    enable = true;

    extraPackages = with pkgs; [
      gh
      fd
      nixfmt
    ];

    settings = {
      autoupdate = false;

      provider.google.options.apiKey = "{file:~/.keys/gemini-google}";

      mcp.context7 = {
        type = "remote";
        url = "https://mcp.context7.com/mcp";
        enabled = true;
        headers.CONTEXT7_API_KEY = "{file:~/.keys/context7}";
      };

      permission = {
        edit = "ask";
        external_directory = {
          "~/nixos/**" = "allow";
          "/mnt/Datos/**" = "allow";
        };
        read = {
          "~/.keys/**" = "deny";
        };
      };
    };

    tui = {
      theme = "system";
    };
  };
}
