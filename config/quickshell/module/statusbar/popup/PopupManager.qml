import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.global

Scope {
    id: root

    required property ShellScreen screen
    required property real frameLeft
    required property real frameRight
    required property real frameBottom

    property bool visible: false
    property bool closing: false
    property bool switching: false
    property real popupX
    property real popupY: root.frameBottom - root.popupHeight
    property real popupWidth
    property real popupHeight
    property real popupPaddingLeft
    property real popupPaddingRight
    property real componentX
    property real componentWidth
    property Component popupContent: null

    NumberAnimation {
        id: heightAnimation

        target: root
        property: "popupHeight"
        duration: 220
        easing.type: Easing.OutCubic

        onFinished: {
            if (!root.closing)
                return

            root.popupHeight = 0
            root.visible = false
            root.popupContent = null
            root.closing = false
        }
    }

    ParallelAnimation {
        id: shiftAnimation

        NumberAnimation {
            id: shiftX

            target: root
            property: "popupX"
            duration: 220
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            id: shiftWidth

            target: root
            property: "popupWidth"
            duration: 220
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            id: shiftHeight

            target: root
            property: "popupHeight"
            duration: 220
            easing.type: Easing.OutCubic
        }

        onFinished: root.switching = false
    }

    property real bgWidth: popupWidth
    property real bgHeight: popupHeight
    property real bgY: popupY + (Config.borderWidth / 2)
    property real bgX: {
        if (root.popupX === root.frameLeft) {
            return root.popupX - (Config.borderWidth / 2)
        } else if (root.popupX + root.popupWidth === root.frameRight) {
            return root.popupX + (Config.borderWidth / 2)
        }
        return root.popupX
    }

    readonly property string popupPath: {
        const left = root.popupX
        const right = root.popupX + root.popupWidth
        const top = root.frameBottom - root.popupHeight
        const bottom = root.frameBottom + (Config.borderWidth / 2)

        if (root.popupX === root.frameLeft) {
            return (
                `M ${left} ${top} ` +
                `L ${right} ${top} ` +
                `L ${right} ${bottom}`
            )
        } else if (root.popupX + root.popupWidth === root.frameRight) {
            return (
                `M ${left} ${bottom} ` +
                `L ${left} ${top} ` +
                `L ${right} ${top}`
            )
        }

        return (
            `M ${left} ${bottom} ` +
            `L ${left} ${top} ` + 
            `L ${right} ${top} ` +
            `L ${right} ${bottom}`
        )
    }

    function open(componentX, componentWidth, popupContent) {
        root.closing = false
        root.switching = root.popupContent !== null
        root.componentX = componentX
        root.componentWidth = componentWidth
        root.popupContent = popupContent
    }

    function close() {
        root.closing = true
        root.switching = false
        shiftAnimation.stop()
        heightAnimation.stop()
        heightAnimation.from = root.popupHeight
        heightAnimation.to = 0
        heightAnimation.start()
    }

    PanelWindow {
        id: overlay

        screen: root.screen
        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }

        visible: root.visible
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        mask: Region {
            x: 0
            y: 0
            width: overlay.width
            height: root.frameBottom
        }
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-statusbar-popup"

        Rectangle {
            x: root.frameLeft
            y: root.frameLeft
            width: root.frameRight - root.frameLeft
            height: root.frameBottom - y
            color: Theme.withAlpha(
                Theme[Config.colors.background], "b3")
        }

        Shape {
            anchors.fill: parent

            ShapePath {
                fillColor: Theme[Config.colors.background]
                capStyle: ShapePath.FlatCap
                strokeWidth: -1

                startX: root.bgX
                startY: root.bgY

                PathLine { x: root.bgX + root.bgWidth; y: root.bgY; }
                PathLine { x: root.bgX + root.bgWidth; y: root.bgY + root.bgHeight; }
                PathLine { x: root.bgX; y: root.bgY + root.bgHeight; }
                PathLine { x: root.bgX; y: root.bgY; }
            }

            ShapePath {
                fillColor: Theme[Config.colors.background]
                strokeColor: Theme[Config.colors.border]
                strokeWidth: Config.borderWidth
                capStyle: ShapePath.FlatCap

                PathSvg {
                    path: popupPath
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }

        MouseArea {
            x: root.popupX
            y: root.popupY
            width: root.popupWidth
            height: root.popupHeight
        }

        Loader {
            id: popupLoader

            clip: true
            x: root.popupX + root.popupPaddingLeft
            y: root.popupY + Config.padding
            width: Math.max(
                0,
                root.popupWidth
                    - root.popupPaddingLeft
                    - root.popupPaddingRight
            )
            height: Math.max(
                0,
                root.popupHeight - Config.padding
            )
            sourceComponent: root.popupContent

            onLoaded: {
                const padding = Config.padding
                const contentWidth = item.implicitWidth
                const contentHeight = item.implicitHeight
                const paddedWidth = contentWidth + padding * 2
                const popupHeight = contentHeight + padding
                const desiredX = root.componentX
                    + (root.componentWidth - paddedWidth) / 2
                const touchesLeft = desiredX <= root.frameLeft
                const touchesRight = desiredX + paddedWidth >= root.frameRight

                root.popupPaddingLeft = touchesLeft ? 0 : padding
                root.popupPaddingRight = touchesRight ? 0 : padding

                const popupWidth = contentWidth
                    + root.popupPaddingLeft
                    + root.popupPaddingRight
                const popupX = touchesLeft
                    ? root.frameLeft
                    : touchesRight
                        ? root.frameRight - popupWidth
                        : desiredX

                if (root.switching) {
                    heightAnimation.stop()
                    shiftAnimation.stop()

                    shiftX.from = root.popupX
                    shiftX.to = popupX
                    shiftWidth.from = root.popupWidth
                    shiftWidth.to = popupWidth
                    shiftHeight.from = root.popupHeight
                    shiftHeight.to = popupHeight

                    shiftAnimation.start()
                    return
                }

                root.popupWidth = popupWidth
                root.popupX = popupX
                root.visible = true
                root.closing = false
                heightAnimation.stop()
                heightAnimation.from = root.popupHeight
                heightAnimation.to = popupHeight
                heightAnimation.start()
            }
        }
    }
}
