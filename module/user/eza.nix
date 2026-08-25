metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
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
