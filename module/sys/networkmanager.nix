{
    lib,
    hostmeta,
    ...
}:
let
    persist = hostmeta.persistence;
in
{
    networking.networkmanager.enable = true;

    environment.persistence.${persist.systemRoot}.directories =
        lib.mkIf persist.enable
            [
                "/etc/NetworkManager/system-connections"
                "/var/lib/NetworkManager"
            ];
}
