metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
{
    lib,
    pkgs,
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
    users.users.${userName}.packages = [
        pkgs.openssh
    ];

    environment.persistence = lib.mkIf persist.enable {
        ${persist.userRoot}.users.${userName}.directories = [
            ".ssh"
        ];
    };
}
