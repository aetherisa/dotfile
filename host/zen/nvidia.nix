{
    config,
    lib,
    ...
}:
{
    nixpkgs.config.allowUnfreePredicate = package:
        lib.getName package == "nvidia-x11";

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.graphics = {
        enable = true;
        enable32Bit = true;
    };

    hardware.nvidia = {
        modesetting.enable = true;
        open = true;
        nvidiaSettings = false;
        package = config.boot.kernelPackages.nvidiaPackages.latest;

        powerManagement = {
            enable = true;
            finegrained = true;
        };

        prime = {
            amdgpuBusId = "PCI:6:0:0";
            nvidiaBusId = "PCI:1:0:0";

            offload = {
                enable = true;
                enableOffloadCmd = true;
            };
        };
    };
}
