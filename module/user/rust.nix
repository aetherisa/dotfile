metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
assert builtins.hasAttr "user.modules.rust" metadata;
assert builtins.hasAttr "user.modules.xdg" metadata;
{
    lib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    cargoHome = "${userHome}/.local/share/cargo";
    environmentConfig = pkgs.writeText "20-rust.conf" ''
        CARGO_HOME=${cargoHome}
        PATH=${cargoHome}/bin:$PATH
    '';
in
{
    users.users.${userName}.packages = with pkgs; [
        cargo
        clippy
        rustc
        rustfmt
    ];

    systemd.tmpfiles.rules = [
        "d ${cargoHome} 0755 ${userName} users -"
        "L+ ${userHome}/.config/environment.d/20-rust.conf - - - - ${environmentConfig}"
    ];

    environment.persistence = lib.mkIf metadata."persistence.enable" {
        ${metadata."persistence.userRoot"}.users.${userName}.directories = [
            ".local/share/cargo"
        ];
    };
}
