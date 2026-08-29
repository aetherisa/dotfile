hostMetadata:
{ dotlib, ... }:
let
    modules = [
        "base"
        "eza"
        "fzf"
        "fish"
		"gum"
        "ghostty"
        "git"
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
            "user.home" = "/home/aetheris";
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

    imports = dotlib.instantiateModules metadata (
        dotlib.resolveUserModules modules
    );
}
