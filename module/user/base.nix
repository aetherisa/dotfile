metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
{ ... }:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
in
{
    systemd.tmpfiles.rules = [
        "d ${userHome}/.config 0755 ${userName} users -"
    ];
}
