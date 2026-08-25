hostMetadata:
{ dotlib, ... }:
let
    metadata = hostMetadata // {
        "user.name" = "aetheris";
        "user.home" = "/home/aetheris";
    };
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

    imports = dotlib.instantiateModules metadata [
        ../module/user/base.nix
        ../module/user/eza.nix
        ../module/user/fzf.nix
        ../module/user/fish.nix
        ../module/user/starship.nix
        ../module/user/zoxide.nix
    ];
}
