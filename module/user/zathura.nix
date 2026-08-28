metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.colors" metadata;
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
{
    lib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    colors = metadata."theme.colors";
    persist = {
        enable = metadata."persistence.enable";
        userRoot = metadata."persistence.userRoot";
    };
    reloadTheme = pkgs.writeShellScript "reload-zathura-theme" ''
        ${pkgs.systemd}/bin/busctl \
            --user \
            --no-legend \
            --no-pager \
            list | while read -r service _; do
                case "$service" in
                    org.pwmt.zathura.PID-*)
                        ${pkgs.systemd}/bin/busctl \
                            --user \
                            call "$service" \
                            /org/pwmt/zathura \
                            org.pwmt.zathura \
                            SourceConfig || true
                        ;;
                esac
            done
    '';
    theme = colors {
        template = ../../template/zathura.template;
    };
    finalConfig = pkgs.concatText "zathurarc" [
        ../../config/zathura/zathurarc
        theme
    ];
in
{
    users.users.${userName}.packages = [
        pkgs.zathura
    ];

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config/zathura 0755 ${userName} users -"
        "L+ ${userHome}/.config/zathura/zathurarc - - - - ${finalConfig}"
    ];

    systemd.user.services."theme-reload-zathura-${userName}" = {
        description = "Reload Zathura after a theme change";
        wantedBy = [ "theme-reload.target" ];
        unitConfig.ConditionUser = userName;
        serviceConfig = {
            Type = "oneshot";
            ExecStart = reloadTheme;
        };
    };

    environment.persistence = lib.mkIf persist.enable {
        ${persist.userRoot}.users.${userName}.directories = [
            ".local/share/zathura"
        ];
    };
}
