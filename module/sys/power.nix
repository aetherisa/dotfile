{
    lib,
    hostmeta,
    ...
}:
let
    persist = hostmeta.persistence;
in
{
    services.power-profiles-daemon.enable = true;

    environment.persistence.${persist.systemRoot}.directories =
        lib.mkIf persist.enable
            [ "/var/lib/power-profiles-daemon" ];
}
