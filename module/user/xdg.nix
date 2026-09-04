metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "user.modules.xdg" metadata;
{
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    userDirsConfig = pkgs.writeText "user-dirs.dirs" ''
        XDG_DESKTOP_DIR="$HOME/"
        XDG_DOWNLOAD_DIR="$HOME/downloads"
        XDG_TEMPLATES_DIR="$HOME/"
        XDG_PUBLICSHARE_DIR="$HOME/"
        XDG_DOCUMENTS_DIR="$HOME/"
        XDG_MUSIC_DIR="$HOME/"
        XDG_PICTURES_DIR="$HOME/pictures"
        XDG_VIDEOS_DIR="$HOME/"
        XDG_PROJECTS_DIR="$HOME/"
    '';
    userDirsControl = pkgs.writeText "user-dirs.conf" ''
        enabled=False
    '';
    environmentConfig = pkgs.writeText "10-xdg.conf" ''
        XDG_CONFIG_HOME=${userHome}/.config
        XDG_DATA_HOME=${userHome}/.local/share
        XDG_CACHE_HOME=${userHome}/.cache
        XDG_STATE_HOME=${userHome}/.local/state
    '';
in
{
    users.users.${userName}.packages = [
        pkgs.xdg-user-dirs
    ];

    systemd.tmpfiles.rules = [
        "d ${userHome}/downloads 0755 ${userName} users -"
        "d ${userHome}/pictures 0755 ${userName} users -"
        "L+ ${userHome}/.config/user-dirs.conf - - - - ${userDirsControl}"
        "L+ ${userHome}/.config/user-dirs.dirs - - - - ${userDirsConfig}"
        "L+ ${userHome}/.config/environment.d/10-xdg.conf - - - - ${environmentConfig}"
    ];
}
