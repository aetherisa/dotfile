metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
assert builtins.hasAttr "theme.default" metadata;
assert builtins.hasAttr "theme.list" metadata;
assert builtins.hasAttr "theme.root" metadata;
assert builtins.hasAttr "user.modules.base" metadata;
{ lib, ... }:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    themeRoot = metadata."theme.root";
    themeRelative = lib.removePrefix "${userHome}/" themeRoot;
in
{
    systemd.user.targets.theme-reload = {
        description = "Reload applications after a theme change";
        unitConfig.StopWhenUnneeded = true;
    };

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config 0755 ${userName} users -"
        "d ${userHome}/.config/environment.d 0755 ${userName} users -"
        "d ${userHome}/.local 0755 ${userName} users -"
        "d ${userHome}/.local/state 0755 ${userName} users -"
        "d ${themeRoot} 0755 ${userName} users -"
    ]
    ++ map (
        theme: "d ${themeRoot}/${theme.name} 0755 ${userName} users -"
    ) metadata."theme.list"
    ++ [
        "L ${themeRoot}/active - - - - ${metadata."theme.default"}"
    ];

    environment.persistence = lib.mkIf metadata."persistence.enable" {
        ${metadata."persistence.userRoot"}.users.${userName}.directories = [
            themeRelative
        ];
    };
}
