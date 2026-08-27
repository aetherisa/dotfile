{
    base16lib,
    dotlib,
    themes,
    ...
}:
let
    metadata = {
        "host.name" = "zen";
        "boot.espMountPoint" = "/boot";
        "persistence.enable" = true;
        "persistence.systemRoot" = "/pin/sys";
        "persistence.userRoot" = "/pin/user";
    }
    // dotlib.mkThemeMetadata {
        inherit base16lib themes;
        name = "everforest-dark-hard";
    };
in
{
    system.stateVersion = "26.11";

    imports =
        dotlib.instantiateModules metadata [
            ../../module/sys/base.nix
            ../../module/sys/bluez.nix
            ../../module/sys/btrfs.nix
            ../../module/sys/networkmanager.nix
            ../../module/sys/power.nix
            ../../module/sys/sudo.nix

            ../../user/aetheris.nix

            ./boot.nix
            ./disk.nix
        ]
        ++ [
            ./hardware.nix
            ./nvidia.nix
        ];
}
