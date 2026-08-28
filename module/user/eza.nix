metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "user.modules.eza" metadata;
{
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
in
{
    users.users.${userName}.packages = [
        pkgs.eza
    ];
}
