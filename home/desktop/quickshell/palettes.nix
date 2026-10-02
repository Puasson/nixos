{ lib }:

let
  families = [
    "abyss-blue"
    "forest-green"
    "violet-haze"
    "holst-red"
    "holst-amber"
    "mono"
    "sakura"
  ];

  labels = {
    "abyss-blue" = "Abyss Blue";
    "forest-green" = "Forest Green";
    "violet-haze" = "Violet Haze";
    "holst-red" = "Holst Red";
    "holst-amber" = "Holst Amber";
    "mono" = "Mono";
    "sakura" = "Sakura";
  };

  slots = [
    "bg"
    "side"
    "thumb"
    "text"
    "main"
    "muted"
    "blue"
    "green"
    "yellow"
    "red"
    "violet"
  ];

  data = {
    "abyss-blue" = {
      dark = {
        bg = "#021024";
        side = "#010913";
        thumb = "#052659";
        text = "#C1E8FF";
        main = "#7DA0CA";
        muted = "#5E84AD";
        blue = "#7DA0CA";
        green = "#5483B3";
        yellow = "#C1E8FF";
        red = "#4A7BA8";
        violet = "#9ABEDD";
      };
      light = {
        bg = "#C1E8FF";
        side = "#A9CCE8";
        thumb = "#A9CCE8";
        text = "#021024";
        main = "#052659";
        muted = "#4E6E96";
        blue = "#16406E";
        green = "#2F5D8A";
        yellow = "#5B7FA6";
        red = "#0B2F57";
        violet = "#3E6E9E";
      };
    };
    "forest-green" = {
      dark = {
        bg = "#051F20";
        side = "#020E0F";
        thumb = "#0B2B26";
        text = "#DAF1DE";
        main = "#BEB69B";
        muted = "#7BA493";
        blue = "#9DC4B0";
        green = "#BEB69B";
        yellow = "#DAF1DE";
        red = "#5E8A7A";
        violet = "#8AB5A3";
      };
      light = {
        bg = "#DAF1DE";
        side = "#C2DCC7";
        thumb = "#C2DCC7";
        text = "#051F20";
        main = "#0B2B26";
        muted = "#4E7367";
        blue = "#163832";
        green = "#235347";
        yellow = "#4A7A62";
        red = "#0B2B26";
        violet = "#386153";
      };
    };
    "violet-haze" = {
      dark = {
        bg = "#49225B";
        side = "#2A1237";
        thumb = "#6E3482";
        text = "#F5EBFA";
        main = "#E7DBEF";
        muted = "#B48AC9";
        blue = "#A56ABD";
        green = "#C49BD8";
        yellow = "#F5EBFA";
        red = "#8A4FA3";
        violet = "#D0B3E3";
      };
      light = {
        bg = "#F5EBFA";
        side = "#E7DBEF";
        thumb = "#E7DBEF";
        text = "#2A1237";
        main = "#49225B";
        muted = "#7E5A94";
        blue = "#49225B";
        green = "#6E3482";
        yellow = "#8A68A8";
        red = "#331640";
        violet = "#7A4E94";
      };
    };
    "holst-red" = {
      dark = {
        bg = "#4B0F1E";
        side = "#24060E";
        thumb = "#6D1D32";
        text = "#F7D6DC";
        main = "#E07A94";
        muted = "#C06A80";
        blue = "#E07A94";
        green = "#CC5671";
        yellow = "#F7D6DC";
        red = "#B23C59";
        violet = "#D98AA0";
      };
      light = {
        bg = "#F7D6DC";
        side = "#EAC0C7";
        thumb = "#EAC0C7";
        text = "#2E0812";
        main = "#4B0F1E";
        muted = "#8A5560";
        blue = "#4B0F1E";
        green = "#6D1D32";
        yellow = "#8E4A5A";
        red = "#2E0812";
        violet = "#8E2B44";
      };
    };
    "holst-amber" = {
      dark = {
        bg = "#2A2206";
        side = "#1A1504";
        thumb = "#5A4A0D";
        text = "#FFF3D8";
        main = "#F3D789";
        muted = "#D0A94E";
        blue = "#F3D789";
        green = "#E8B84A";
        yellow = "#FFF3D8";
        red = "#CC961F";
        violet = "#DDBB6A";
      };
      light = {
        bg = "#FFF3D8";
        side = "#F0DC9F";
        thumb = "#F0DC9F";
        text = "#2A2206";
        main = "#5A4A0D";
        muted = "#8A6E22";
        blue = "#5A4A0D";
        green = "#7A5E12";
        yellow = "#8A6E22";
        red = "#2A2206";
        violet = "#A67917";
      };
    };
    "mono" = {
      dark = {
        bg = "#06151E";
        side = "#02090D";
        thumb = "#2A3438";
        text = "#FFFFFF";
        main = "#D6D6D6";
        muted = "#898A8C";
        blue = "#D6D6D6";
        green = "#9AA0A2";
        yellow = "#FFFFFF";
        red = "#7E8587";
        violet = "#B8BDC0";
      };
      light = {
        bg = "#FFFFFF";
        side = "#D6D6D6";
        thumb = "#D6D6D6";
        text = "#06151E";
        main = "#2A3438";
        muted = "#6E7375";
        blue = "#06151E";
        green = "#2E383C";
        yellow = "#545A5B";
        red = "#1A2A33";
        violet = "#3E4A50";
      };
    };
    "sakura" = {
      dark = {
        bg = "#240B0E";
        side = "#150608";
        thumb = "#4A222B";
        text = "#FFDADD";
        main = "#FAA3AF";
        muted = "#B07A86";
        blue = "#C9CCEC";
        green = "#FAA3AF";
        yellow = "#FFDADD";
        red = "#E07A94";
        violet = "#C48A99";
      };
      light = {
        bg = "#FFDADD";
        side = "#EFC2C8";
        thumb = "#EFC2C8";
        text = "#240B0E";
        main = "#5A2E38";
        muted = "#8A6470";
        blue = "#4A5A9E";
        green = "#7F4D5E";
        yellow = "#A86A78";
        red = "#5A1A26";
        violet = "#8A4E62";
      };
    };
  };

  get = family: mode: data.${family}.${mode};

  qmlEntry = p: "{ ${lib.concatMapStringsSep ", " (s: "${s}: \"${p.${s}}\"") slots} }";

  qmlFile = ''
    pragma Singleton
    import Quickshell
    import QtQuick

    // Generado por palettes.nix — NO editar a mano.
    Scope {
        function base(fam, dark): var {
  ''
  + lib.concatMapStrings (fam: ''
    if (fam === "${fam}") {
        if (dark)
            return ${qmlEntry data.${fam}.dark};
        return ${qmlEntry data.${fam}.light};
    }
  '') families
  + ''
        // Fallback: primera familia en dark (families valida antes).
        return ${qmlEntry data.${builtins.head families}.dark};
        }
    }
  '';

  kittyFile =
    family: mode:
    let
      p = get family mode;
      black = if mode == "dark" then p.side else p.text;
      white = if mode == "dark" then p.text else p.bg;
    in
    ''
      # ${family} ${mode} — generado por palettes.nix, NO editar.
      background ${p.bg}
      foreground ${p.main}
      cursor ${p.blue}
      cursor_text_color ${p.bg}
      selection_background ${p.blue}
      selection_foreground ${p.bg}
      color0 ${black}
      color8 ${p.muted}
      color1 ${p.red}
      color9 ${p.red}
      color2 ${p.green}
      color10 ${p.green}
      color3 ${p.yellow}
      color11 ${p.yellow}
      color4 ${p.blue}
      color12 ${p.blue}
      color5 ${p.violet}
      color13 ${p.violet}
      color6 ${p.green}
      color14 ${p.green}
      color7 ${white}
      color15 ${white}
      url_color ${p.blue}
      active_border_color ${p.blue}
      inactive_border_color ${p.thumb}
      active_tab_background ${p.blue}
      active_tab_foreground ${p.bg}
      inactive_tab_background ${p.thumb}
      inactive_tab_foreground ${p.muted}
      tab_bar_background ${p.side}
    '';

  gtkCssFile =
    family: mode:
    let
      p = get family mode;
      shade = if mode == "dark" then "rgba(0, 0, 0, 0.36)" else "rgba(0, 0, 0, 0.12)";
    in
    ''
      /* ${family} ${mode} — generado por palettes.nix, NO editar. */
      @define-color window_bg_color ${p.bg};
      @define-color window_fg_color ${p.text};
      @define-color view_bg_color ${p.bg};
      @define-color view_fg_color ${p.main};
      @define-color headerbar_bg_color ${p.side};
      @define-color headerbar_fg_color ${p.text};
      @define-color headerbar_border_color ${p.thumb};
      @define-color headerbar_backdrop_color @window_bg_color;
      @define-color headerbar_shade_color ${shade};
      @define-color card_bg_color ${p.thumb};
      @define-color card_fg_color ${p.main};
      @define-color card_shade_color ${shade};
      @define-color dialog_bg_color ${p.side};
      @define-color dialog_fg_color ${p.text};
      @define-color popover_bg_color ${p.side};
      @define-color popover_fg_color ${p.text};
      @define-color shade_color ${shade};
      @define-color scrollbar_outline_color ${shade};
      @define-color accent_bg_color ${p.blue};
      @define-color accent_fg_color ${p.bg};
      @define-color accent_color ${p.blue};
      @define-color destructive_bg_color ${p.red};
      @define-color destructive_fg_color ${p.bg};
      @define-color destructive_color ${p.red};
      @define-color success_bg_color ${p.green};
      @define-color success_fg_color ${p.bg};
      @define-color success_color ${p.green};
      @define-color warning_bg_color ${p.yellow};
      @define-color warning_fg_color ${p.bg};
      @define-color warning_color ${p.yellow};
      @define-color error_bg_color ${p.red};
      @define-color error_fg_color ${p.bg};
      @define-color error_color ${p.red};
    '';

in
{
  inherit
    families
    labels
    data
    get
    qmlFile
    kittyFile
    gtkCssFile
    ;
}
