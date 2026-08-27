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
    localpkgs = import ../../package { inherit pkgs; };
    persist = {
        enable = metadata."persistence.enable";
        userRoot = metadata."persistence.userRoot";
    };
in
{
    users.users.${userName}.packages = [
        localpkgs.zen-browser
    ];

    environment.persistence = lib.mkIf persist.enable {
        ${persist.userRoot}.users.${userName}.directories = [
            ".config/zen"
        ];
    };
}
