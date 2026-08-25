{
    description = "Aetheris' NixOS Config";

    inputs = {
        # nix packages
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

        # formatter
        treefmt-nix = {
            url = "github:numtide/treefmt-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # theme parser and Base16 scheme collection
        base16.url = "github:SenchoPens/base16.nix";
        themes = {
            url = "github:tinted-theming/schemes";
            flake = false;
        };

        # persist file
        impermanence.url = "github:nix-community/impermanence";

        # disk device manager
        disko = {
            url = "github:nix-community/disko";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        {
            self,
            nixpkgs,
            treefmt-nix,
            base16,
            themes,
            impermanence,
            disko,
        }:
        let
            system = "x86_64-linux";
            hosts = [ "zen" ];
            pkgs = import nixpkgs { inherit system; };
        in
        {
            formatter.${system} = treefmt-nix.lib.mkWrapper pkgs {
                projectRootFile = "flake.nix";
                programs.nixfmt.enable = true;
                settings.formatter.nixfmt.options = [
                    "--indent"
                    "4"
                    "--width"
                    "80"
                ];
            };

            nixosConfigurations = nixpkgs.lib.genAttrs hosts (
                name:
                nixpkgs.lib.nixosSystem {
                    inherit system;
                    modules = [
                        disko.nixosModules.disko
                        impermanence.nixosModules.impermanence
                        ./host/${name}
                    ];
                }
            );
        };
}
