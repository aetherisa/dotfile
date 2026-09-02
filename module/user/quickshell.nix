metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.list" metadata;
assert builtins.hasAttr "theme.root" metadata;
assert builtins.hasAttr "user.modules.quickshell" metadata;
{
    dotlib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    themeRoot = metadata."theme.root";
    config = ../../config/quickshell;

    quickshell = pkgs.quickshell.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [
            pkgs.qt6.qtquick3d
        ];
    });

    themeRules = dotlib.mkThemeFiles {
        inherit themeRoot;
        themes = metadata."theme.list";
        template = ../../template/quickshell.mustache;
        fileName = "quickshell";
    };
in
{
    users.users.${userName}.packages = [
        quickshell
        pkgs.imagemagick
        pkgs.lutgen
    ];

    systemd.tmpfiles.rules = themeRules ++ [
        "d ${userHome}/.config/quickshell 0755 ${userName} users -"
        "L+ ${userHome}/.config/quickshell/shell.qml - - - - ${config}/shell.qml"
        "L+ ${userHome}/.config/quickshell/Theme.qml - - - - ${config}/Theme.qml"
        "L+ ${userHome}/.config/quickshell/Wallpaper.qml - - - - ${config}/Wallpaper.qml"
        "L+ ${userHome}/.config/quickshell/assets - - - - ${config}/assets"
        "L+ ${userHome}/.config/quickshell/theme.json - - - - ${themeRoot}/active/quickshell"
    ];
}
