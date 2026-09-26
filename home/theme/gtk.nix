{ pkgs, ... }:

{
  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    iconTheme = {
      name = "WhiteSur-dark";
      package = pkgs.whitesur-icon-theme;
    };

    cursorTheme = {
      name = "Vimix-cursors";
      package = pkgs.vimix-cursors;
      size = 24;
    };

    font = {
      name = "Ubuntu Sans";
      size = 11;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraCss = ''
      .nautilus-window {
        background-color: #1e1e2e;
      }
    '';
  };

  dconf = {
    enable = true;

    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # Estado inicial oscuro. El cambio en runtime lo maneja `theme-set`
  # (dconf + gsettings); no fijar GTK_THEME aqui porque pisaria el
  # toggle para apps lanzadas via `uwsm app`.
}
