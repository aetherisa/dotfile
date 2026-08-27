{
    appimageTools,
    fetchurl,
    lib,
}:

let
    pname = "zen-browser";
    version = "1.21.15b";

    src = fetchurl {
        url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-x86_64.AppImage";
        hash = "sha256-NJcEhxUi4AhfO1BdYpAJSQ7vs/Bu5nqH6hBtyxOVzP4=";
    };

    contents = appimageTools.extract {
        inherit pname version src;
    };
in
appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
        ln -s $out/bin/zen-browser $out/bin/zen

        install -Dm444 \
            ${contents}/zen.desktop \
            $out/share/applications/zen.desktop

        install -Dm444 \
            ${contents}/zen.png \
            $out/share/icons/hicolor/128x128/apps/zen.png
    '';

    meta = {
        description = "Firefox-based browser focused on privacy and customization";
        homepage = "https://zen-browser.app";
        license = lib.licenses.mpl20;
        mainProgram = "zen";
        platforms = [ "x86_64-linux" ];
    };
}
