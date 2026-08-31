metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "cursor.name" metadata;
assert builtins.hasAttr "cursor.size" metadata;
assert builtins.hasAttr "user.modules.base" metadata;
assert builtins.hasAttr "user.modules.cursor" metadata;
{ pkgs, ... }:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    cursorName = metadata."cursor.name";
    cursorSize = metadata."cursor.size";
    environment = pkgs.writeText "20-cursor.conf" ''
        XCURSOR_THEME="${cursorName}"
        XCURSOR_SIZE="${toString cursorSize}"
    '';
in
{
    users.users.${userName}.packages = [
        pkgs.bibata-cursors
    ];

    systemd.tmpfiles.rules = [
        "d ${userHome}/.local/share/icons 0755 ${userName} users -"
        "L+ ${userHome}/.local/share/icons/${cursorName} - - - - ${pkgs.bibata-cursors}/share/icons/${cursorName}"
        "L+ ${userHome}/.config/environment.d/20-cursor.conf - - - - ${environment}"
    ];
}
