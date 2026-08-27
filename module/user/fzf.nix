metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.colors" metadata;
{
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    colors = metadata."theme.colors";
    originalConfig = builtins.readFile ../../config/fzf/options;
    finalConfig = pkgs.writeText "fzf-options" ''
        ${originalConfig}

        --color=bg+:#${colors.base01},bg:#${colors.base00},spinner:#${colors.base0C},hl:#${colors.base0D}
        --color=fg:#${colors.base04},header:#${colors.base0D},info:#${colors.base0A},pointer:#${colors.base0C}
        --color=marker:#${colors.base0C},fg+:#${colors.base06},prompt:#${colors.base0A},hl+:#${colors.base0D}
    '';
in
{
    users.users.${userName}.packages = [
        pkgs.fzf
    ];

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config/fzf 0755 ${userName} users -"
        "L+ ${userHome}/.config/fzf/options - - - - ${finalConfig}"
    ];
}
