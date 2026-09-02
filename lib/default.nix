{
    lib,
    pkgs,
    themeDir,
    yamlParser,
}:
{
    instantiateModules = import ./instantiate-modules.nix;
    mkModuleMetadata = import ./mk-module-metadata.nix;
    mkThemeFiles = import ./mk-theme-files.nix { inherit pkgs; };
    mkThemeMetadata = import ./mk-theme-metadata.nix {
        inherit lib themeDir yamlParser;
    };
    resolveUserModules = import ./resolve-user-modules.nix;
}
