metadata:
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.systemRoot" metadata;
{
    lib,
    ...
}:
let
    persist = {
        enable = metadata."persistence.enable";
        systemRoot = metadata."persistence.systemRoot";
    };
in
{
    services.power-profiles-daemon.enable = true;

    environment.persistence = lib.mkIf persist.enable {
        ${persist.systemRoot}.directories = [ "/var/lib/power-profiles-daemon" ];
    };
}
