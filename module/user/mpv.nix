metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.list" metadata;
assert builtins.hasAttr "theme.root" metadata;
assert builtins.hasAttr "user.modules.mpv" metadata;
{
    dotlib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    themeRoot = metadata."theme.root";
    config = ../../config/mpv;
    themeRules = dotlib.mkThemeFiles {
        inherit themeRoot;
        themes = metadata."theme.list";
        template = ../../template/mpv.mustache;
        fileName = "mpv";
    };
in
{
    users.users.${userName}.packages = [
        pkgs.mpv
    ];

    systemd.tmpfiles.rules = themeRules ++ [
        "d ${userHome}/.config/mpv 0755 ${userName} users -"
        "L+ ${userHome}/.config/mpv/mpv.conf - - - - ${config}/mpv.conf"
        "L+ ${userHome}/.config/mpv/input.conf - - - - ${config}/input.conf"
        "L+ ${userHome}/.config/mpv/scripts - - - - ${config}/scripts"
        "L+ ${userHome}/.config/mpv/script-opts - - - - ${config}/script-opts"
        "L+ ${userHome}/.config/mpv/fonts - - - - ${config}/fonts"
        "L+ ${userHome}/.config/mpv/theme.conf - - - - ${themeRoot}/active/mpv"
    ];
}
