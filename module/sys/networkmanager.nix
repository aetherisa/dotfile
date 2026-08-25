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
    networking.networkmanager.enable = true;

    environment.persistence = lib.mkIf persist.enable {
        ${persist.systemRoot}.directories = [
            "/etc/NetworkManager/system-connections"
            "/var/lib/NetworkManager"
        ];
    };
}
