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
    shaders = ../../config/ghostty/shaders;
    reloadTheme = pkgs.writeShellScript "reload-ghostty-theme" ''
        ${pkgs.systemd}/bin/systemctl \
            --user \
            reload app-com.mitchellh.ghostty.service \
            2>/dev/null || \
            ${pkgs.procps}/bin/pkill -USR2 -x ghostty \
            2>/dev/null || true
    '';
    theme = colors {
        template = ../../template/ghostty.mustache;
    };
    finalConfig = pkgs.concatText "ghostty-config" [
        ../../config/ghostty/config.ghostty
        theme
    ];
in
{
    users.users.${userName}.packages = [
        pkgs.ghostty
    ];

    systemd.tmpfiles.rules = [
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
