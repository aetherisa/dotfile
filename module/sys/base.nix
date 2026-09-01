metadata:
assert builtins.hasAttr "host.name" metadata;
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.systemRoot" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
{
    pkgs,
    lib,
    self,
    ...
}:
let
    persist = {
        enable = metadata."persistence.enable";
        systemRoot = metadata."persistence.systemRoot";
        userRoot = metadata."persistence.userRoot";
    };
in
{
    networking.hostName = metadata."host.name";

    time.timeZone = "Canada/Pacific";

    i18n.defaultLocale = "en_US.UTF-8";
    console.keyMap = "us";

    nix.registry.dot.flake = self;

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

    fileSystems = lib.mkIf persist.enable {
        ${persist.systemRoot}.neededForBoot = true;
        ${persist.userRoot}.neededForBoot = true;
    };

    environment.persistence = lib.mkIf persist.enable {
        ${persist.systemRoot} = {
            files = [
                "/etc/machine-id"
                "/var/lib/systemd/random-seed"
            ];

            directories = [
                "/var/lib/nixos"
                "/var/lib/userborn"
                "/var/lib/systemd/timers"
            ];
        };
    };

    users.mutableUsers = true;

    services.userborn = {
        enable = true;
        passwordFilesLocation =
            if persist.enable then "${persist.systemRoot}/etc" else "/etc";
    };
}
