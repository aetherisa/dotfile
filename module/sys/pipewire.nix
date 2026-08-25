metadata:
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
{
    config,
    lib,
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
    security.rtkit.enable = true;

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
    };

    environment.persistence = lib.mkIf persist.enable {
        ${persist.userRoot}.users = lib.mapAttrs (_: _: {
            directories = [ ".local/state/wireplumber" ];
        }) normalUsers;
    };
}
