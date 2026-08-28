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
            lib = nixpkgs.lib;
            dotlib = import ./lib;
            base16lib = pkgs.callPackage base16.lib { };
            localpkgs = import ./package { inherit pkgs; };

            nixosConfigurations = nixpkgs.lib.genAttrs hosts (
                name:
                nixpkgs.lib.nixosSystem {
                    inherit system;
                    specialArgs = {
                        inherit
                            base16lib
                            dotlib
                            localpkgs
                            themes
                            ;
                    };
                    modules = [
                        disko.nixosModules.disko
                        impermanence.nixosModules.impermanence
                        ./host/${name}
                    ];
                }
            );
        in
        {
            inherit nixosConfigurations;

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

            apps.${system} =
                let
                    normalUsers = lib.mapAttrs (
                        _: host:
                        builtins.attrNames (
                            lib.filterAttrs (_: user: user.isNormalUser) host.config.users.users
                        )
                    ) nixosConfigurations;

                    hostUsersFile = pkgs.writeText "host-users.json" (builtins.toJSON normalUsers);

                    installOS = pkgs.writeShellApplication {
                        name = "install";

                        runtimeInputs = [
                            disko.packages.${system}.disko
                            pkgs.coreutils
                            pkgs.fish
                            pkgs.jq
                            pkgs.gum
                            pkgs.nixos-install-tools
                            pkgs.util-linux
                        ];

                        text = ''
                            exec ${pkgs.fish}/bin/fish \
                                ${./script/install.fish} \
                                --flake ${self} \
                                --host-users ${hostUsersFile} \
                                "$@"
                        '';
                    };
                in
                {
                    install = {
                        type = "app";
                        program = lib.getExe installOS;
                    };
                };
        };
}
