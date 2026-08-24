{ ... }:
{
    system.stateVersion = "26.11";

    imports = [
        ../../module/sys/base.nix
        ../../module/sys/bluez.nix
        ../../module/sys/btrfs.nix
        ../../module/sys/networkmanager.nix
        ../../module/sys/pipewire.nix
        ../../module/sys/power.nix
        ../../module/sys/ssh.nix
        ../../module/sys/sudo.nix

        ../../user/aetheris.nix

        ./boot.nix
        ./disk.nix
        ./hardware.nix
    ];
}
