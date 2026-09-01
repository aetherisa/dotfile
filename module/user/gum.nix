metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.list" metadata;
assert builtins.hasAttr "theme.root" metadata;
assert builtins.hasAttr "user.modules.gum" metadata;
{
    dotlib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    themeRoot = metadata."theme.root";
    themeRules = dotlib.mkThemeFiles {
        inherit themeRoot;
        themes = metadata."theme.list";
        template = ../../template/gum.mustache;
        fileName = "gum";
    };
in
{
    users.users.${userName}.packages = [
        pkgs.gum
    ];

    systemd.tmpfiles.rules = themeRules ++ [
        "L+ ${userHome}/.config/environment.d/20-gum.conf - - - - ${themeRoot}/active/gum"
    ];
}
