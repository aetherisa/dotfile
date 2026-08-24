{
    config,
    lib,
    hostmeta,
    ...
}:
let
    persist = hostmeta.persistence;
    normalUsers = lib.filterAttrs (_: user: user.isNormalUser) config.users.users;
in
{
    security.rtkit.enable = true;

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
    };

    environment.persistence.${persist.userRoot}.users = lib.mkIf persist.enable (
        lib.mapAttrs (_: _: {
            directories = [ ".local/state/wireplumber" ];
        }) normalUsers
    );
}
