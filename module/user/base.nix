metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "user.modules.base" metadata;
{ ... }:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
in
{
    systemd.user.targets.theme-reload = {
        description = "Reload applications after a theme change";
        unitConfig.StopWhenUnneeded = true;
    };

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config 0755 ${userName} users -"
        "d ${userHome}/.config/environment.d 0755 ${userName} users -"
    ];
}
