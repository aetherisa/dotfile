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
            hosts = [
                "zen"
                "vm"
            ];
            pkgs = import nixpkgs { inherit system; };
            dotlib = import ./lib { inherit pkgs base16 themes; };
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
                let
                    hostmeta = import ./host/${name}/meta.nix { inherit dotlib; };
                in
                nixpkgs.lib.nixosSystem {
                    inherit system;
                    specialArgs = { inherit hostmeta; };
                    modules = [
                        disko.nixosModules.disko
                        impermanence.nixosModules.impermanence
                        ./host/${name}
                    ];
                }
            );
        };
}
