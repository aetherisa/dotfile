metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "theme.list" metadata;
assert builtins.hasAttr "theme.root" metadata;
assert builtins.hasAttr "user.modules.gum" metadata;
{
    dotlib,
    lib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    themeRoot = metadata."theme.root";
    themeRules = dotlib.mkThemeFiles {
        inherit themeRoot;
        themes = metadata."theme.list";
        template = ../../template/gum.mustache;
        fileName = "gum";
    };
    gum = pkgs.writeShellApplication {
        name = "gum";
        text = ''
            set -a
            # shellcheck disable=SC1091
            source ${themeRoot}/active/gum
            set +a

            exec ${lib.getExe pkgs.gum} "$@"
        '';
    };
in
{
    users.users.${userName}.packages = [
        gum
    ];

    systemd.tmpfiles.rules = themeRules;
}
