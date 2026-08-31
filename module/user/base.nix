metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "user.modules.base" metadata;
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
{ lib, ... }:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    persist = {
        enable = metadata."persistence.enable";
        userRoot = metadata."persistence.userRoot";
    };
in
{
    systemd.user.targets.theme-reload = {
        description = "Reload applications after a theme change";
        unitConfig.StopWhenUnneeded = true;
    };

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config 0755 ${userName} users -"
    ];

    environment.persistence = lib.mkIf persist.enable {
        ${persist.userRoot}.users.${userName}.directories = [
            "pin"
        ];
    };
}
