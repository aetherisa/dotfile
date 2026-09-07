metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.modules.base-devel" metadata;
{
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
in
{
    users.users.${userName}.packages = with pkgs; [
        cmake
        gnumake
        pkg-config
        stdenv.cc
    ];
}
