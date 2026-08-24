{ dotlib }:
dotlib.mkHostMeta {
    hostName = "vm";
    themeName = "everforest-dark-hard";

    boot.espMountPoint = "/boot";

    persistence = {
        enable = true;
        systemRoot = "/pin/sys";
        userRoot = "/pin/user";
    };
}
