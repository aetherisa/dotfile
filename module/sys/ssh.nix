metadata:
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
{
    config,
    lib,
    pkgs,
    ...
}:
let
    persist = {
        enable = metadata."persistence.enable";
        userRoot = metadata."persistence.userRoot";
    };
    normalUsers = lib.filterAttrs (_: user: user.isNormalUser) config.users.users;
in
{
    environment.systemPackages = [ pkgs.openssh ];

    environment.persistence = lib.mkIf persist.enable {
        ${persist.userRoot}.users = lib.mapAttrs (_: _: {
            directories = [ ".ssh" ];
        }) normalUsers;
    };
}
