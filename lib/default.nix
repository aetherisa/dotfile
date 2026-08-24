{
    pkgs,
    base16,
    themes,
}:
let
    base16Lib = pkgs.callPackage base16.lib { };
in
{
    mkHostMeta = import ./mk-host-meta.nix {
        inherit base16Lib themes;
    };
}
