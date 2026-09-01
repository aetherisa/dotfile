metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "theme.list" metadata;
assert builtins.hasAttr "theme.root" metadata;
assert builtins.hasAttr "user.modules.fzf" metadata;
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
        template = ../../template/fzf.mustache;
        fileName = "fzf";
    };
    fzf = pkgs.writeShellApplication {
        name = "fzf";
        text = ''
            set -a
            # shellcheck disable=SC1091
            source ${../../config/fzf/options}
            # shellcheck disable=SC1091
            source ${themeRoot}/active/fzf
            set +a

            exec ${lib.getExe pkgs.fzf} "$@"
        '';
    };
in
{
    users.users.${userName}.packages = [
        fzf
    ];

    systemd.tmpfiles.rules = themeRules;
}
