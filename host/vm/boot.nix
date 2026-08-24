{
    pkgs,
    hostmeta,
    ...
}:
{
    boot.loader = {
        systemd-boot.enable = false;

        efi = {
            efiSysMountPoint = hostmeta.boot.espMountPoint;
            canTouchEfiVariables = true;
        };

        grub = {
            enable = true;
            efiSupport = true;
            device = "nodev";
            useOSProber = true;

            font = "${pkgs.nerd-fonts.terminess-ttf}/share/fonts/truetype/NerdFonts/Terminess/TerminessNerdFontMono-Bold.ttf";
            fontSize = 36;
        };
    };
}
