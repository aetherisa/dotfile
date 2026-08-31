metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
assert builtins.hasAttr "user.modules.fish" metadata;
assert builtins.hasAttr "user.modules.eza" metadata;
assert builtins.hasAttr "user.modules.fzf" metadata;
assert builtins.hasAttr "user.modules.neovim" metadata;
assert builtins.hasAttr "user.modules.starship" metadata;
assert builtins.hasAttr "user.modules.zoxide" metadata;
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
    programs.fish.useBabelfish = true;

    users.users.${userName} = {
        shell = pkgs.fish;
        packages = with pkgs; [
            fish
            less
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
