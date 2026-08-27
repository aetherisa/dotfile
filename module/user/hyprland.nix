metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
{
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    config = ../../config/hypr;
    localpkgs = import ../../package { inherit pkgs; };
in
{
    programs.hyprland = {
        enable = true;
        xwayland.enable = true;
    };

    xdg.portal.extraPortals = [
        pkgs.xdg-desktop-portal-gtk
    ];

    users.users.${userName}.packages = [
        pkgs.brightnessctl
        pkgs.ghostty
        pkgs.wireplumber
        localpkgs.zen-browser
    ];

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config/hypr 0755 ${userName} users -"
        "L+ ${userHome}/.config/hypr/hyprland.lua - - - - ${config}/hyprland.lua"
        "L+ ${userHome}/.config/hypr/apps.lua - - - - ${config}/apps.lua"
        "L+ ${userHome}/.config/hypr/config - - - - ${config}/config"
    ];
}
