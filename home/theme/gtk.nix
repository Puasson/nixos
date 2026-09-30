{ pkgs, ... }:

{
  gtk = {
    enable = true;

    # Defaults de fallback: el dueño runtime es `theme-apply`, que mantiene
    # settings.ini + dconf en sync con el modo (claro/oscuro) en cada login
    # (autostart), cambio de tema y `hms` (themeApplyCached). No hardcodear
    # aqui valores por modo: HM los reescribiria sobre el modo claro.
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
    # Sin `style` a proposito: fijar adwaita-dark exportaria
    # QT_STYLE_OVERRIDE=adwaita-dark a toda la sesion y forzaria Qt en
    # oscuro de forma permanente (una env no se puede cambiar en runtime).
    # Con platformTheme gtk3, Qt sigue al tema GTK que `theme-apply`
    # mantiene sincronizado con el modo.
    platformTheme.name = "gtk3";
  };
}
