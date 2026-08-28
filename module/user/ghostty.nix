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
    originalConfig = builtins.readFile ../../config/ghostty/config.ghostty;
    shaders = ../../config/ghostty/shaders;
    reloadTheme = pkgs.writeShellScript "reload-ghostty-theme" ''
        ${pkgs.systemd}/bin/systemctl \
            --user \
            reload app-com.mitchellh.ghostty.service \
            2>/dev/null || \
            ${pkgs.procps}/bin/pkill -USR2 -x ghostty \
            2>/dev/null || true
    '';
    finalConfig = pkgs.writeText "ghostty-config" ''
        ${originalConfig}

        # base16 colors
        background = #${colors.base00}
        foreground = #${colors.base05}

        selection-background = #${colors.base02}
        selection-foreground = #${colors.base00}

        palette = 0=#${colors.base00}
        palette = 1=#${colors.base08}
        palette = 2=#${colors.base0B}
        palette = 3=#${colors.base0A}
        palette = 4=#${colors.base0D}
        palette = 5=#${colors.base0E}
        palette = 6=#${colors.base0C}
        palette = 7=#${colors.base05}
        palette = 8=#${colors.base03}
        palette = 9=#${colors.base08}
        palette = 10=#${colors.base0B}
        palette = 11=#${colors.base0A}
        palette = 12=#${colors.base0D}
        palette = 13=#${colors.base0E}
        palette = 14=#${colors.base0C}
        palette = 15=#${colors.base07}
        palette = 16=#${colors.base09}
        palette = 17=#${colors.base0F}
        palette = 18=#${colors.base01}
        palette = 19=#${colors.base02}
        palette = 20=#${colors.base04}
        palette = 21=#${colors.base06}
    '';
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
