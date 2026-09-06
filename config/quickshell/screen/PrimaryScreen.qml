import Quickshell
import qs.module.screenPicker
import qs.module.wallpaper
import qs.module.statusbar
import qs.module.launcher

Scope {
    id: root

    required property ShellScreen screen

    Wallpaper3D {
        screen: root.screen
    }

    ScreenPicker {
        screen: root.screen
    }

    StatusBar {
        screen: root.screen
    }

    Launcher {
        screen: root.screen
    }
}
