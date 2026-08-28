{
    instantiateModules = import ./instantiate-modules.nix;
    mkModuleMetadata = import ./mk-module-metadata.nix;
    mkThemeMetadata = import ./mk-theme-metadata.nix;
    resolveUserModules = import ./resolve-user-modules.nix;
}
