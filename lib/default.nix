{
    base16lib,
    themes,
}:
{
    instantiateModules = import ./instantiate-modules.nix;
    mkModuleMetadata = import ./mk-module-metadata.nix;
    mkThemeFiles = import ./mk-theme-files.nix;
    mkThemeMetadata = import ./mk-theme-metadata.nix {
        inherit base16lib themes;
    };
    resolveUserModules = import ./resolve-user-modules.nix;
}
