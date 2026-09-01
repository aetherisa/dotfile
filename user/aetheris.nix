hostMetadata:
assert builtins.hasAttr "persistence.enable" hostMetadata;
assert builtins.hasAttr "persistence.userRoot" hostMetadata;
{
    dotlib,
    lib,
    base16lib,
    themes,
    pkgs,
    ...
}:
let
    userHome = "/home/aetheris";
    modules = [
        "base"
        "codex"
        "cursor"
        "eza"
        "fzf"
        "fish"
        "gum"
        "ghostty"
        "git"
        "gtk"
        "hyprland"
        "neovim"
        "pipewire"
        "ssh"
        "starship"
        "xdg"
        "zathura"
        "zen-browser"
        "zoxide"
    ];
    metadata =
        hostMetadata
        // {
            "user.name" = "aetheris";
            "user.home" = userHome;
            "cursor.name" = "Bibata-Modern-Ice";
            "cursor.size" = 24;
        }
        // dotlib.mkThemeMetadata {
            inherit base16lib themes userHome;
            default = "everforest-dark-medium";
            list = [
                {
                    name = "everforest-dark-medium";
                    mode = "dark";
                }
                {
                    name = "everforest-light-medium";
                    mode = "light";
                }
                {
                    name = "nord";
                    mode = "dark";
                }
                {
                    name = "gruvbox-dark-medium";
                    mode = "dark";
                }
                {
                    name = "catppuccin-mocha";
                    mode = "dark";
                }
                {
                    name = "dracula";
                    mode = "dark";
                }
                {
                    name = "tokyo-night-storm";
                    mode = "dark";
                }
            ];
        }
        // dotlib.mkModuleMetadata modules;
in
{
    users.users.${metadata."user.name"} = {
        isNormalUser = true;
        home = metadata."user.home";
        createHome = true;
        group = "users";
        extraGroups = [
            "wheel"
            "audio"
            "video"
        ];
        initialPassword = "1234";
    };

    systemd.services."getty@tty1" = {
        overrideStrategy = "asDropin";
        serviceConfig.ExecStart = [
            ""
            "@${lib.getExe' pkgs.util-linux "agetty"} agetty --autologin ${metadata."user.name"} --noclear %I $TERM"
        ];
    };

    environment.persistence = lib.mkIf metadata."persistence.enable" {
        ${metadata."persistence.userRoot"}.users.${metadata."user.name"}.directories = [
            "dotfile"
        ];
    };

    imports = dotlib.instantiateModules metadata (
        dotlib.resolveUserModules modules
    );
}
