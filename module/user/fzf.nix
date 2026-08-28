metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.colors" metadata;
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
    finalConfig = pkgs.concatText "fzf-options" [
        ../../config/fzf/options
        theme
    ];
in
{
    users.users.${userName}.packages = [
        pkgs.fzf
    ];

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config/fzf 0755 ${userName} users -"
        "L+ ${userHome}/.config/fzf/options - - - - ${finalConfig}"
    ];
}
