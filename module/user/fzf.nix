metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.colors" metadata;
assert builtins.hasAttr "user.modules.fzf" metadata;
{
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    colors = metadata."theme.colors";
    theme = colors {
        template = ../../template/fzf.mustache;
    };
    finalConfig = pkgs.concatText "20-fzf.conf" [
        ../../config/fzf/options
        theme
    ];
in
{
    users.users.${userName}.packages = [
        pkgs.fzf
    ];

    systemd.tmpfiles.rules = [
        "L+ ${userHome}/.config/environment.d/20-fzf.conf - - - - ${finalConfig}"
    ];
}
