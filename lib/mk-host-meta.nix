{
    base16Lib,
    themes,
}:
{
    hostName,
    themeName,
    boot ? { },
    persistence ? { },
}:
let
    bootDefaults = {
        espMountPoint = "/boot";
    };

    persistenceDefaults = {
        enable = false;
        systemRoot = "/persist/system";
        userRoot = "/persist/user";
    };
in
{
    name = hostName;

    style.theme = {
        name = themeName;
    }
    // base16Lib.mkSchemeAttrs ("${themes}/base16/${themeName}.yaml");

    boot = bootDefaults // boot;
    persistence = persistenceDefaults // persistence;
}
