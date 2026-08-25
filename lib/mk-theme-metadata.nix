{
    base16lib,
    themes,
    name,
}:
let
    schemeFile = "${themes}/base16/${name}.yaml";
in
assert builtins.pathExists schemeFile;
{
    "theme.name" = name;
    "theme.colors" = base16lib.mkSchemeAttrs schemeFile;
}
