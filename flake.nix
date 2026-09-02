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

        # YAML parser for the local theme collection
        fromYaml = {
            url = "github:SenchoPens/fromYaml";
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
            fromYaml,
            impermanence,
            disko,
        }:
        let
            system = "x86_64-linux";
            hosts = [ "zen" ];
            pkgs = import nixpkgs { inherit system; };
            lib = nixpkgs.lib;
            yamlParser = import "${fromYaml}/fromYaml.nix" { inherit lib; };
            dotlib = import ./lib {
                inherit lib pkgs yamlParser;
                themeDir = ./theme;
            };
            localpkgs = import ./package { inherit pkgs; };

            nixosConfigurations = nixpkgs.lib.genAttrs hosts (
                name:
                nixpkgs.lib.nixosSystem {
                    inherit system;
                    specialArgs = {
                        inherit
                            self
                            dotlib
                            localpkgs
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
                    installData = lib.mapAttrs (_: host: {
                        disks = builtins.attrNames host.config.disko.devices.disk;
                    }) nixosConfigurations;

                    installDataFile = pkgs.writeText "install-data.json" (
                        builtins.toJSON installData
                    );

                    rebuildDataFile = pkgs.writeText "rebuild-data.json" (
                        builtins.toJSON (builtins.attrNames nixosConfigurations)
                    );

                    installOS = pkgs.writeShellApplication {
                        name = "install";

                        runtimeInputs = [
                            disko.packages.${system}.disko
                            pkgs.fish
                            pkgs.jq
                            pkgs.gum
                            pkgs.util-linux
                        ];

                        text = ''
                            exec ${pkgs.fish}/bin/fish \
                                ${./script/install.fish} \
                                --flake ${self} \
                                --install-data ${installDataFile} \
                                "$@"
                        '';
                    };

                    rebuildOS = pkgs.writeShellApplication {
                        name = "rebuild";

                        runtimeInputs = [
                            pkgs.fish
                            pkgs.jq
                            pkgs.gum
                            pkgs.nixos-rebuild
                            pkgs.systemd
                        ];

                        text = ''
                            exec ${pkgs.fish}/bin/fish \
                                ${./script/rebuild.fish} \
                                --flake ${self} \
                                --rebuild-data ${rebuildDataFile} \
                            "$@"
                        '';
                    };

                    themeOS = pkgs.writeShellApplication {
                        name = "theme";

                        runtimeInputs = [
                            pkgs.coreutils
                            pkgs.fish
                            pkgs.jq
                            pkgs.gum
                            pkgs.systemd
                        ];

                        text = ''
                            exec ${pkgs.fish}/bin/fish \
                                ${./script/theme.fish} \
                                --theme-data "/etc/dotfile/theme/$USER.json" \
                                "$@"
                        '';
                    };
                in
                {
                    install = {
                        type = "app";
                        program = lib.getExe installOS;
                    };

                    rebuild = {
                        type = "app";
                        program = lib.getExe rebuildOS;
                    };

                    theme = {
                        type = "app";
                        program = lib.getExe themeOS;
                    };
                };
        };
}
