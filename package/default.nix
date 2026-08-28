{ pkgs }:
{
    bareline-nvim = pkgs.callPackage ./bareline-nvim.nix { };
    tiny-cmdline-nvim = pkgs.callPackage ./tiny-cmdline-nvim.nix { };
    zen-browser = pkgs.callPackage ./zen-browser.nix { };
}
