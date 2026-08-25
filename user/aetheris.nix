hostMetadata:
{ ... }:
let
    dotlib = import ../lib;
    metadata = hostMetadata // {
        "user.name" = "aetheris";
        "user.home" = "/home/aetheris";
    };
in
{
    # User-level modules will be instantiated here as they are added.
    imports = dotlib.instantiateModules metadata [ ];
}
