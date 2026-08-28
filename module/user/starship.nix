metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "user.modules.starship" metadata;
{
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    config = ../../config/starship/starship.toml;
in
{
    users.users.${userName}.packages = [
        pkgs.starship
    ];

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config/starship 0755 ${userName} users -"
        "L+ ${userHome}/.config/starship/starship.toml - - - - ${config}"
    ];
}
