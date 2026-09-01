metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.list" metadata;
assert builtins.hasAttr "theme.root" metadata;
assert builtins.hasAttr "user.modules.fzf" metadata;
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
        template = ../../template/fzf.mustache;
        fileName = "fzf";
    };
in
{
    users.users.${userName}.packages = [
        pkgs.fzf
    ];

    systemd.tmpfiles.rules = themeRules ++ [
        "L+ ${userHome}/.config/environment.d/20-fzf.conf - - - - ${../../config/fzf/options}"
        "L+ ${userHome}/.config/environment.d/21-fzf-theme.conf - - - - ${themeRoot}/active/fzf"
    ];
}
