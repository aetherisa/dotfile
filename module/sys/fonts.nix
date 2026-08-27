_:
{ pkgs, ... }:
{
    fonts = {
        packages = with pkgs; [
            nerd-fonts.caskaydia-cove
            nerd-fonts.terminess-ttf
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-color-emoji
        ];

        fontconfig = {
            enable = true;

            defaultFonts = {
                monospace = [ "CaskaydiaCove Nerd Font" ];
                sansSerif = [ "Noto Sans" ];
                serif = [ "Noto Serif" ];
                emoji = [ "Noto Color Emoji" ];
            };
        };
    };
}
