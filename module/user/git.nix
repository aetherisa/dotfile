metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "user.modules.git" metadata;
{
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    config = ../../config/git/config;
in
{
    users.users.${userName}.packages = [
        pkgs.git
    ];

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config/git 0755 ${userName} users -"
        "L+ ${userHome}/.config/git/config - - - - ${config}"
    ];
}
