metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.colors" metadata;
assert builtins.hasAttr "user.modules.fzf" metadata;
assert builtins.hasAttr "user.modules.fish" metadata;
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
    finalConfig = pkgs.concatText "fzf.fish" [
        ../../config/fzf/options
        theme
    ];
in
{
    users.users.${userName}.packages = [
        pkgs.fzf
    ];

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config/fish/conf.d 0755 ${userName} users -"
        "L+ ${userHome}/.config/fish/conf.d/fzf.fish - - - - ${finalConfig}"
    ];
}
