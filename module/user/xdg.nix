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
    config = ../../config/xdg/user-dirs.dirs;
in
{
    users.users.${userName}.packages = [
        pkgs.xdg-user-dirs
    ];

    systemd.tmpfiles.rules = [
        "L+ ${userHome}/.config/user-dirs.dirs - - - - ${config}"
    ];
}
