metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
assert builtins.hasAttr "user.modules.codex" metadata;
assert builtins.hasAttr "user.modules.xdg" metadata;
{
    lib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    persist = {
        enable = metadata."persistence.enable";
        userRoot = metadata."persistence.userRoot";
    };
    environmentConfig = pkgs.writeText "20-codex.conf" ''
        CODEX_HOME=$XDG_STATE_HOME/codex
    '';
in
{
    users.users.${userName}.packages = [
        pkgs.codex
    ];

    systemd.tmpfiles.rules = [
        "L+ ${userHome}/.config/environment.d/20-codex.conf - - - - ${environmentConfig}"
    ];

    environment.persistence = lib.mkIf persist.enable {
        ${persist.userRoot}.users.${userName}.directories = [
            ".local/state/codex"
        ];
    };
}
