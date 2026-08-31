{
    base16lib,
    themes,
    name,
    mode,
}:
let
    schemeFile = "${themes}/base16/${name}.yaml";
in
assert builtins.pathExists schemeFile;
assert builtins.elem mode [ "dark" "light" ];
{
    "theme.name" = name;
    "theme.mode" = mode;
    "theme.colors" = base16lib.mkSchemeAttrs schemeFile;
}
