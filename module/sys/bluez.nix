{
    lib,
    hostmeta,
    ...
}:
let
    persist = hostmeta.persistence;
in
{
    hardware.bluetooth.enable = true;

    environment.persistence.${persist.systemRoot}.directories =
        lib.mkIf persist.enable
            [ "/var/lib/bluetooth" ];
}
