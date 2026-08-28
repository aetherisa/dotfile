metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
assert builtins.hasAttr "user.modules.pipewire" metadata;
{
    lib,
    ...
}:
let
    userName = metadata."user.name";
    persist = {
        enable = metadata."persistence.enable";
        userRoot = metadata."persistence.userRoot";
    };
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
        ${persist.userRoot}.users.${userName}.directories = [
            ".local/state/wireplumber"
        ];
    };
}
