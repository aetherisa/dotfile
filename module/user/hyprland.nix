metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.list" metadata;
assert builtins.hasAttr "theme.root" metadata;
assert builtins.hasAttr "user.modules.hyprland" metadata;
assert builtins.hasAttr "user.modules.brightnessctl" metadata;
assert builtins.hasAttr "user.modules.ghostty" metadata;
assert builtins.hasAttr "user.modules.pipewire" metadata;
assert builtins.hasAttr "user.modules.zen-browser" metadata;
assert builtins.hasAttr "user.modules.quickshell" metadata;
{
    dotlib,
    lib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    themeRoot = metadata."theme.root";
    uwsm = lib.getExe pkgs.uwsm;
    config = ../../config/hypr;
    themeRules = dotlib.mkThemeFiles {
        inherit themeRoot;
        themes = metadata."theme.list";
        template = ../../template/hyprland.mustache;
        fileName = "hyprland";
    };
in
{
    programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        withUWSM = true;
    };

    xdg.portal.extraPortals = [
        pkgs.xdg-desktop-portal-gtk
    ];

    systemd.tmpfiles.rules = themeRules ++ [
        "d ${userHome}/.config/hypr 0755 ${userName} users -"
        "L+ ${userHome}/.config/hypr/hyprland.lua - - - - ${config}/hyprland.lua"
        "L+ ${userHome}/.config/hypr/apps.lua - - - - ${config}/apps.lua"
        "L+ ${userHome}/.config/hypr/config - - - - ${config}/config"
        "L+ ${userHome}/.config/hypr/theme.lua - - - - ${themeRoot}/active/hyprland"
    ];

    systemd.user.services."theme-reload-hyprland-${userName}" = {
        description = "Reload Hyprland after a theme change";
        wantedBy = [ "theme-reload.target" ];
        unitConfig.ConditionUser = userName;
        serviceConfig = {
            Type = "oneshot";
            ExecStart = "${lib.getExe' pkgs.hyprland "hyprctl"} reload config-only";
        };
    };

    environment.loginShellInit = ''
        if [ "$USER" = ${lib.escapeShellArg userName} ] && ${uwsm} check may-start; then
            exec ${uwsm} start hyprland.desktop
        fi
    '';
}
