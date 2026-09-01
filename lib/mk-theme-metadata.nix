{
    base16lib,
    themes,
    userHome,
    default,
    list,
}:
let
    names = map (theme: theme.name) list;
    uniqueNames = builtins.attrNames (
        builtins.listToAttrs (
            map (name: {
                inherit name;
                value = null;
            }) names
        )
    );

    validTheme =
        theme:
        builtins.elem theme.mode [
            "dark"
            "light"
        ]
        && builtins.pathExists "${themes}/base16/${theme.name}.yaml";
in
assert builtins.elem default names;
assert builtins.length names == builtins.length uniqueNames;
assert builtins.all validTheme list;
{
    "theme.default" = default;
    "theme.root" = "${userHome}/.local/state/theme";
    "theme.list" = map (
        theme:
        theme
        // {
            colors = base16lib.mkSchemeAttrs "${themes}/base16/${theme.name}.yaml";
        }
    ) list;
}
