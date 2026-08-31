metadata:
assert builtins.hasAttr "boot.espMountPoint" metadata;
{
    pkgs,
    ...
}:
{
    boot.loader = {
        systemd-boot.enable = false;

        efi = {
            efiSysMountPoint = metadata."boot.espMountPoint";
            canTouchEfiVariables = true;
        };

        grub = {
            enable = true;
            efiSupport = true;
            device = "nodev";
            useOSProber = true;
            splashImage = null;

            font = "${pkgs.nerd-fonts.terminess-ttf}/share/fonts/truetype/NerdFonts/Terminess/TerminessNerdFontMono-Bold.ttf";
            fontSize = 36;
        };
    };
}
