{
    config,
    lib,
    pkgs,
    hostmeta,
    ...
}:
let
    persist = hostmeta.persistence;
    normalUsers = lib.filterAttrs (_: user: user.isNormalUser) config.users.users;
in
{
    environment.systemPackages = [ pkgs.openssh ];

    environment.persistence.${persist.userRoot}.users = lib.mkIf persist.enable (
        lib.mapAttrs (_: _: {
            directories = [ ".ssh" ];
        }) normalUsers
    );
}
