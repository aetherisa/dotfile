{ pkgs }:
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
            data = pkgs.writeText "${theme.name}-${fileName}-theme-data.json" (
                builtins.toJSON colors
            );
            rendered =
                pkgs.runCommand "${theme.name}-${fileName}"
                    {
                        nativeBuildInputs = [ pkgs.mustache-go ];
                    }
                    ''
                        mustache ${data} ${template} > "$out"
                    '';
        in
        assert builtins.elem theme.mode [
            "dark"
            "light"
        ];
        "L+ ${themeRoot}/${theme.name}/${fileName} - - - - ${rendered}";
in
assert builtins.baseNameOf fileName == fileName;
map mkThemeFile themes
