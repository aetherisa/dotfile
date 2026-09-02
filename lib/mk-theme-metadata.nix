{
    lib,
    themeDir,
    yamlParser,
}:
{
    userHome,
    default,
    list,
}:
let
    names = list;
    uniqueNames = builtins.attrNames (
        builtins.listToAttrs (
            map (name: {
                inherit name;
                value = null;
            }) names
        )
    );

    colorNames = [
        "base00"
        "base01"
        "base02"
        "base03"
        "base04"
        "base05"
        "base06"
        "base07"
        "base08"
        "base09"
        "base0A"
        "base0B"
        "base0C"
        "base0D"
        "base0E"
        "base0F"
    ];

    loadTheme =
        name:
        let
            path = themeDir + "/${name}.yaml";
            raw = yamlParser (builtins.readFile path);
            normalizeColor = color: lib.toLower (lib.removePrefix "#" color);
            validColor =
                color:
                builtins.isString color
                && builtins.match "[0-9a-fA-F]{6}" (normalizeColor color) != null;
            validPalette =
                raw ? palette
                && builtins.all (
                    colorName:
                    builtins.hasAttr colorName raw.palette && validColor raw.palette.${colorName}
                ) colorNames;
            colors =
                builtins.listToAttrs (
                    map (colorName: {
                        name = "${colorName}-hex";
                        value = normalizeColor raw.palette.${colorName};
                    }) colorNames
                )
                // {
                    "scheme-name" = raw.name;
                    "scheme-author" = raw.author or "unknown";
                    "scheme-slug" = raw.slug or name;
                };
        in
        assert builtins.pathExists path;
        assert builtins.isString (raw.name or null);
        assert (raw.slug or name) == name;
        assert builtins.elem (raw.mode or null) [
            "dark"
            "light"
        ];
        assert validPalette;
        {
            inherit colors name;
            mode = raw.mode;
        };
in
assert builtins.elem default names;
assert builtins.length names == builtins.length uniqueNames;
{
    "theme.default" = default;
    "theme.root" = "${userHome}/.local/state/theme";
    "theme.list" = map loadTheme list;
}
