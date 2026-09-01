{
    themeRoot,
    themes,
    template,
    fileName,
}:
let
    mkThemeFile =
        theme:
        let
            colors = theme.colors // {
                "theme-mode" = theme.mode;
                "is-dark" = theme.mode == "dark";
                "is-light" = theme.mode == "light";
            };
            rendered = colors { inherit template; };
        in
        assert builtins.elem theme.mode [
            "dark"
            "light"
        ];
        "L+ ${themeRoot}/${theme.name}/${fileName} - - - - ${rendered}";
in
assert builtins.baseNameOf fileName == fileName;
map mkThemeFile themes
