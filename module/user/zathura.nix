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
    originalConfig = builtins.readFile ../../config/zathura/zathurarc;
    finalConfig = pkgs.writeText "zathurarc" ''
        ${originalConfig}

        # Base16 ${colors."scheme-name"}
        # Author: ${colors."scheme-author"}

        set default-bg                  ""
        set default-fg                  "#${colors.base05}"

        set statusbar-bg                "#${colors.base00}"
        set statusbar-fg                "#${colors.base05}"

        set inputbar-bg                 "#${colors.base00}"
        set inputbar-fg                 "#${colors.base05}"

        set notification-bg             "#${colors.base00}"
        set notification-fg             "#${colors.base05}"

        set notification-error-bg       "#${colors.base00}"
        set notification-error-fg       "#${colors.base08}"

        set notification-warning-bg     "#${colors.base00}"
        set notification-warning-fg     "#${colors.base09}"

        set completion-bg               "#${colors.base00}"
        set completion-fg               "#${colors.base05}"

        set completion-highlight-bg     "#${colors.base0B}"
        set completion-highlight-fg     "#${colors.base00}"

        set completion-group-bg         "#${colors.base01}"
        set completion-group-fg         "#${colors.base05}"

        set index-bg                    "#${colors.base00}"
        set index-fg                    "#${colors.base05}"

        set index-active-bg             "#${colors.base0B}"
        set index-active-fg             "#${colors.base00}"

        set recolor-lightcolor          "#${colors.base00}"
        set recolor-darkcolor           "#${colors.base05}"
    '';
in
{
    users.users.${userName}.packages = [
        pkgs.zathura
    ];

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config/zathura 0755 ${userName} users -"
        "L+ ${userHome}/.config/zathura/zathurarc - - - - ${finalConfig}"
    ];

    environment.persistence = lib.mkIf persist.enable {
        ${persist.userRoot}.users.${userName}.directories = [
            ".local/share/zathura"
        ];
    };
}
