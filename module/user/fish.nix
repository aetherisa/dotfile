metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
{
    lib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    config = ../../config/fish/config.fish;
    persist = {
        enable = metadata."persistence.enable";
        userRoot = metadata."persistence.userRoot";
    };
in
{
    programs.fish.enable = true;

    users.users.${userName} = {
        shell = pkgs.fish;
        packages = with pkgs; [
            eza
            fish
            fzf
            less
            neovim
            starship
            zoxide
        ];
    };

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config/fish 0755 ${userName} users -"
        "L+ ${userHome}/.config/fish/config.fish - - - - ${config}"
    ];

    environment.persistence = lib.mkIf persist.enable {
        ${persist.userRoot}.users.${userName}.directories = [
            ".local/share/fish"
        ];
    };
}
