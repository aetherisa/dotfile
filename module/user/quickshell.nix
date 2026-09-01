metadata:
assert builtins.hasAttr "user.name" metadata;
{
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    quickshell = pkgs.quickshell.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [
            pkgs.qt6.qtquick3d
        ];
    });
in
{
    users.users.${userName}.packages = [
        quickshell
    ];
}
