{ dotlib }:
dotlib.mkHostMeta {
    hostName = "zen";
    themeName = "everforest-dark-hard";

    boot.espMountPoint = "/boot";

    persistence = {
        enable = true;
        systemRoot = "/pin/sys";
        userRoot = "/pin/user";
    };
}
