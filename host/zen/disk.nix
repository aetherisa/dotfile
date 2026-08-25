metadata:
assert builtins.hasAttr "boot.espMountPoint" metadata;
assert builtins.hasAttr "persistence.systemRoot" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
{ config, ... }:
{
    disko.devices.disk.main = {
        type = "disk";
        device = "REPLACEME";
        content = {
            type = "gpt";
            partitions = {
                ESP = {
                    size = "1G";
                    type = "EF00";
                    content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = metadata."boot.espMountPoint";
                        mountOptions = [ "umask=0077" ];
                    };
                };
                system = {
                    size = "100%";
                    content = {
                        type = "btrfs";
                        extraArgs = [ "-f" ];
                        subvolumes = {
                            "@root" = {
                                mountpoint = "/";
                                mountOptions = [ "compress=zstd" ];
                            };
                            "@log" = {
                                mountpoint = "/var/log";
                                mountOptions = [ "compress=zstd" ];
                            };
                            "@pin" = {
                                mountpoint = metadata."persistence.systemRoot";
                                mountOptions = [ "compress=zstd" ];
                            };
                            "@upin" = {
                                mountpoint = metadata."persistence.userRoot";
                                mountOptions = [ "compress=zstd" ];
                            };
                            "@nix" = {
                                mountpoint = "/nix";
                                mountOptions = [
                                    "compress=zstd"
                                    "noatime"
                                ];
                            };
                        };
                    };
                };
            };
        };
    };

    boot.initrd.systemd.services.reset-root = {
        description = "Recreate ephemeral Btrfs root";
        wantedBy = [ "initrd.target" ];
        requires = [ "initrd-root-device.target" ];
        after = [ "initrd-root-device.target" ];
        before = [ "sysroot.mount" ];

        unitConfig.DefaultDependencies = false;
        serviceConfig.Type = "oneshot";

        script = ''
            mkdir -p /btrfs_tmp

            mount \
                -t btrfs \
                -o subvolid=5 \
                ${config.fileSystems."/".device} \
                /btrfs_tmp

            if [[ -e /btrfs_tmp/@root ]]; then
                btrfs subvolume delete \
                    --recursive \
                    /btrfs_tmp/@root
            fi

            btrfs subvolume create \
                /btrfs_tmp/@root

            umount /btrfs_tmp
        '';
    };
}
