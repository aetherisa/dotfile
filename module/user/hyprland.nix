metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "user.modules.hyprland" metadata;
assert builtins.hasAttr "user.modules.ghostty" metadata;
assert builtins.hasAttr "user.modules.pipewire" metadata;
assert builtins.hasAttr "user.modules.zen-browser" metadata;
{
    lib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    uwsm = lib.getExe pkgs.uwsm;
    config = ../../config/hypr;
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

    users.users.${userName}.packages = [
        pkgs.brightnessctl
    ];

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config/hypr 0755 ${userName} users -"
        "L+ ${userHome}/.config/hypr/hyprland.lua - - - - ${config}/hyprland.lua"
        "L+ ${userHome}/.config/hypr/apps.lua - - - - ${config}/apps.lua"
        "L+ ${userHome}/.config/hypr/config - - - - ${config}/config"
    ];

    environment.loginShellInit = ''
        if [ "$USER" = ${lib.escapeShellArg userName} ] && ${uwsm} check may-start; then
            exec ${uwsm} start hyprland.desktop
        fi
    '';
}
