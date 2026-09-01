metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.list" metadata;
assert builtins.hasAttr "theme.root" metadata;
assert builtins.hasAttr "user.modules.ghostty" metadata;
{
    dotlib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    themeRoot = metadata."theme.root";
    shaders = ../../config/ghostty/shaders;
    reloadTheme = pkgs.writeShellScript "reload-ghostty-theme" ''
        ${pkgs.procps}/bin/pkill -USR2 ghostty || true
    '';
    themeRules = dotlib.mkThemeFiles {
        inherit themeRoot;
        themes = metadata."theme.list";
        template = ../../template/ghostty.mustache;
        fileName = "ghostty";
    };
    themeConfig = pkgs.writeText "ghostty-theme-config" ''
        config-file = ${themeRoot}/active/ghostty
    '';
    finalConfig = pkgs.concatText "ghostty-config" [
        ../../config/ghostty/config.ghostty
        themeConfig
    ];
in
{
    users.users.${userName}.packages = [
        pkgs.ghostty
    ];

    systemd.tmpfiles.rules = themeRules ++ [
        "d ${userHome}/.config/ghostty 0755 ${userName} users -"
        "L+ ${userHome}/.config/ghostty/config.ghostty - - - - ${finalConfig}"
        "L+ ${userHome}/.config/ghostty/shaders - - - - ${shaders}"
    ];

    systemd.user.services."theme-reload-ghostty-${userName}" = {
        description = "Reload Ghostty after a theme change";
        wantedBy = [ "theme-reload.target" ];
        unitConfig.ConditionUser = userName;
        serviceConfig = {
            Type = "oneshot";
            ExecStart = reloadTheme;
        };
    };
}
