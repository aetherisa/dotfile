{
    pkgs,
    lib,
    hostmeta,
    ...
}:
let
    persist = hostmeta.persistence;
in
{
    networking.hostName = hostmeta.name;

    time.timeZone = "Canada/Pacific";

    i18n.defaultLocale = "en_US.UTF-8";
    console.keyMap = "us";

    services.dbus.implementation = "dbus";

    environment.systemPackages = with pkgs; [
        neovim
        git
        curl
        wget
        ripgrep
        fd
        jq
        file
        tree
        unzip
        zip
        pciutils
        usbutils
    ];

    nix = {
        settings.experimental-features = [
            "nix-command"
            "flakes"
        ];

        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
        };

        optimise = {
            automatic = true;
            dates = [ "weekly" ];
        };
    };

    fileSystems.${persist.systemRoot}.neededForBoot = lib.mkIf persist.enable true;
    fileSystems.${persist.userRoot}.neededForBoot = lib.mkIf persist.enable true;

    environment.persistence.${persist.systemRoot} = lib.mkIf persist.enable {
        files = [
            "/etc/machine-id"
            "/etc/shadow"
            "/var/lib/systemd/random-seed"
        ];

        directories = [
            "/var/lib/nixos"
            "/var/lib/systemd/timers"
        ];
    };
}
