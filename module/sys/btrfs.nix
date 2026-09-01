metadata:
assert builtins.hasAttr "persistence.systemRoot" metadata;
{ ... }:
{
    services.btrfs.autoScrub.enable = true;

    swapDevices = [
        {
            device = "${metadata."persistence.systemRoot"}/swapfile";
            size = 16 * 1024; # 16G
        }
    ];
}
