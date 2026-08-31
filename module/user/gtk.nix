metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.colors" metadata;
assert builtins.hasAttr "theme.mode" metadata;
assert builtins.hasAttr "user.modules.base" metadata;
assert builtins.hasAttr "user.modules.gtk" metadata;
{ pkgs, ... }:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    colors = metadata."theme.colors";
    mode = metadata."theme.mode";
    preferDark = if mode == "dark" then "true" else "false";
    gtk3Settings = pkgs.writeText "gtk3-settings.ini" ''
        [Settings]
        gtk-application-prefer-dark-theme=${preferDark}
    '';
    gtk4Settings = pkgs.writeText "gtk4-settings.ini" ''
        [Settings]
        gtk-application-prefer-dark-theme=${preferDark}
    '';
    gtk3Theme = colors {
        template = ../../template/gtk3.mustache;
    };
    gtk4Theme = colors {
        template = ../../template/gtk4.mustache;
    };
    reloadTheme = pkgs.writeShellScript "reload-gtk-theme" ''
        ${pkgs.systemd}/bin/systemctl \
            --user \
            try-restart xdg-desktop-portal-gtk.service
    '';
in
{
    systemd.tmpfiles.rules = [
        "d ${userHome}/.config/gtk-3.0 0755 ${userName} users -"
        "L+ ${userHome}/.config/gtk-3.0/gtk.css - - - - ${gtk3Theme}"
        "L+ ${userHome}/.config/gtk-3.0/settings.ini - - - - ${gtk3Settings}"
        "d ${userHome}/.config/gtk-4.0 0755 ${userName} users -"
        "L+ ${userHome}/.config/gtk-4.0/gtk.css - - - - ${gtk4Theme}"
        "L+ ${userHome}/.config/gtk-4.0/settings.ini - - - - ${gtk4Settings}"
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
