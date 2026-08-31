metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.colors" metadata;
assert builtins.hasAttr "user.modules.gum" metadata;
{
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    colors = metadata."theme.colors";
    finalConfig = colors {
        template = ../../template/gum.mustache;
    };
in
{
    users.users.${userName}.packages = [
        pkgs.gum
    ];

    systemd.tmpfiles.rules = [
        "L+ ${userHome}/.config/environment.d/20-gum.conf - - - - ${finalConfig}"
    ];
}
