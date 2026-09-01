metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.list" metadata;
assert builtins.hasAttr "theme.root" metadata;
assert builtins.hasAttr "cursor.name" metadata;
assert builtins.hasAttr "cursor.size" metadata;
assert builtins.hasAttr "user.modules.base" metadata;
assert builtins.hasAttr "user.modules.cursor" metadata;
assert builtins.hasAttr "user.modules.gtk" metadata;
{
    dotlib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    themeRoot = metadata."theme.root";
    cursorName = metadata."cursor.name";
    cursorSize = metadata."cursor.size";
    settingsTemplate = pkgs.writeText "gtk-settings.mustache" ''
        [Settings]
        gtk-application-prefer-dark-theme={{#is-dark}}true{{/is-dark}}{{#is-light}}false{{/is-light}}
        gtk-cursor-theme-name=${cursorName}
        gtk-cursor-theme-size=${toString cursorSize}
    '';
    gtk3Rules = dotlib.mkThemeFiles {
        inherit themeRoot;
        themes = metadata."theme.list";
        template = ../../template/gtk3.mustache;
        fileName = "gtk3";
    };
    gtk4Rules = dotlib.mkThemeFiles {
        inherit themeRoot;
        themes = metadata."theme.list";
        template = ../../template/gtk4.mustache;
        fileName = "gtk4";
    };
    settingsRules = dotlib.mkThemeFiles {
        inherit themeRoot;
        themes = metadata."theme.list";
        template = settingsTemplate;
        fileName = "gtk-settings";
    };
    reloadTheme = pkgs.writeShellScript "reload-gtk-theme" ''
        ${pkgs.systemd}/bin/systemctl \
            --user \
            try-restart xdg-desktop-portal-gtk.service
    '';
in
{
    systemd.tmpfiles.rules =
        gtk3Rules
        ++ gtk4Rules
        ++ settingsRules
        ++ [
            "d ${userHome}/.config/gtk-3.0 0755 ${userName} users -"
            "L+ ${userHome}/.config/gtk-3.0/gtk.css - - - - ${themeRoot}/active/gtk3"
            "L+ ${userHome}/.config/gtk-3.0/settings.ini - - - - ${themeRoot}/active/gtk-settings"
            "d ${userHome}/.config/gtk-4.0 0755 ${userName} users -"
            "L+ ${userHome}/.config/gtk-4.0/gtk.css - - - - ${themeRoot}/active/gtk4"
            "L+ ${userHome}/.config/gtk-4.0/settings.ini - - - - ${themeRoot}/active/gtk-settings"
        ];

    systemd.user.services."theme-reload-gtk-${userName}" = {
        description = "Reload GTK portal after a theme change";
        wantedBy = [ "theme-reload.target" ];
        unitConfig.ConditionUser = userName;
        serviceConfig = {
            Type = "oneshot";
            ExecStart = reloadTheme;
        };
    };
}
