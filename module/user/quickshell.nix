metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.list" metadata;
assert builtins.hasAttr "theme.root" metadata;
assert builtins.hasAttr "brightness.device" metadata;
assert builtins.hasAttr "user.modules.brightnessctl" metadata;
assert builtins.hasAttr "user.modules.quickshell" metadata;
{
    config,
    dotlib,
    lib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    themeRoot = metadata."theme.root";
    quickshellConfig = ../../config/quickshell;

    quickshell = pkgs.quickshell.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [
            pkgs.qt6.qtquick3d
        ];
    });

    themeRules = dotlib.mkThemeFiles {
        inherit themeRoot;
        themes = metadata."theme.list";
        template = ../../template/quickshell.mustache;
        fileName = "quickshell";
    };
in
{
    users.users.${userName}.packages = [
        quickshell
        pkgs.imagemagick
        pkgs.lutgen
    ];

    systemd.tmpfiles.rules = themeRules ++ [
        "d ${userHome}/.config/quickshell 0755 ${userName} users -"
        "L+ ${userHome}/.config/quickshell/shell.qml - - - - ${quickshellConfig}/shell.qml"
        "L+ ${userHome}/.config/quickshell/config.json - - - - ${quickshellConfig}/config.json"
        "L+ ${userHome}/.config/quickshell/global - - - - ${quickshellConfig}/global"
        "L+ ${userHome}/.config/quickshell/module - - - - ${quickshellConfig}/module"
        "L+ ${userHome}/.config/quickshell/screen - - - - ${quickshellConfig}/screen"
        "L+ ${userHome}/.config/quickshell/assets - - - - ${quickshellConfig}/assets"
        "L+ ${userHome}/.config/quickshell/theme.json - - - - ${themeRoot}/active/quickshell"
    ];

    systemd.user.services.quickshell = {
        description = "Quickshell desktop shell";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        unitConfig.ConditionUser = userName;
        restartTriggers = [ quickshellConfig ];
        path = config.users.users.${userName}.packages ++ [
            pkgs.bash
            pkgs.grim
            pkgs.imagemagick
            pkgs.lutgen
            pkgs.wl-clipboard
            pkgs.wf-recorder
        ];
        serviceConfig = {
            ExecStart = lib.getExe quickshell;
            Restart = "on-failure";
        };
    };

    systemd.user.services."theme-reload-quickshell-${userName}" = {
        description = "Reload Quickshell after a theme change";
        wantedBy = [ "theme-reload.target" ];
        unitConfig.ConditionUser = userName;
        serviceConfig = {
            Type = "oneshot";
            ExecStart = "-${lib.getExe quickshell} ipc call theme reload";
        };
    };
}
