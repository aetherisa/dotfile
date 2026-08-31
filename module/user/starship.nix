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
    environmentConfig = pkgs.writeText "20-starship.conf" ''
        STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/starship.toml
    '';
in
{
    users.users.${userName}.packages = [
        pkgs.starship
    ];

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config/starship 0755 ${userName} users -"
        "L+ ${userHome}/.config/starship/starship.toml - - - - ${config}"
        "L+ ${userHome}/.config/environment.d/20-starship.conf - - - - ${environmentConfig}"
    ];
}
