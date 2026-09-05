metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "brightness.device" metadata;
assert builtins.hasAttr "user.modules.brightnessctl" metadata;
{
    lib,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    device = metadata."brightness.device";
    brightnessctl = pkgs.writeShellApplication {
        name = "brightnessctl";
        text = ''
            exec ${lib.getExe pkgs.brightnessctl} \
                --device ${lib.escapeShellArg device} \
                "$@"
        '';
    };
in
{
    users.users.${userName}.packages = [
        brightnessctl
    ];
}
