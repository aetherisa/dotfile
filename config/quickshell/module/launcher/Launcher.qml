import QtQuick
import QtQuick.Shapes
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland
import qs.global

Scope {
    id: root

    required property ShellScreen screen

    readonly property int unit: Config.unit
    readonly property int padding: Config.padding
    readonly property int rowHeight: root.unit
    readonly property int maximumVisibleRows: Config.launcher.maximumRows
    readonly property real frameTop: Config.padding
    readonly property real launcherWidth: root.unit * Config.launcher.width
    readonly property real collapsedHeight: root.rowHeight + root.padding * 2
    readonly property var applications: {
        const query = searchInput.text.trim().toLowerCase()
        if (query.length === 0)
            return []

        return [...DesktopEntries.applications.values]
            .map(application => ({
                application: application,
                score: root.matchScore(application, query)
            }))
            .filter(result => result.score >= 0)
            .sort((left, right) => {
                if (left.score !== right.score)
                    return left.score - right.score

                return left.application.name.localeCompare(
                    right.application.name)
            })
            .map(result => result.application)
    }
    readonly property int resultRows: Math.ceil(root.applications.length / 2)
    readonly property real resultHeight: root.rowHeight * Math.min(
        root.maximumVisibleRows,
        root.resultRows
    )
    readonly property real desiredHeight: root.collapsedHeight
        + (root.resultHeight > 0
            ? root.padding + root.resultHeight
            : 0)

    property bool closing: false
    property real launcherHeight: 0
    property int selectedIndex: 0

    function matchScore(application, query): int {
        const name = (application.name || "").toLowerCase()
        const genericName = (application.genericName || "").toLowerCase()
        const keywords = [...application.keywords]
            .map(keyword => keyword.toLowerCase())

        if (name === query)
            return 0
        if (name.startsWith(query))
            return 1
        if (name.split(/\s+/).some(word => word.startsWith(query)))
            return 2
        if (name.includes(query))
            return 3
        if (genericName.startsWith(query))
            return 4
        if (genericName.includes(query))
            return 5
        if (keywords.some(keyword => keyword.includes(query)))
            return 6

        return -1
    }

    function open(): void {
        heightAnimation.stop()
        root.closing = false
        root.selectedIndex = 0
        searchInput.text = ""
        overlay.visible = true
        root.launcherHeight = 0
        heightAnimation.to = root.collapsedHeight
        heightAnimation.start()
        Qt.callLater(() => searchInput.forceActiveFocus())
    }

    function close(): void {
        if (!overlay.visible || root.closing)
            return

        root.closing = true
        heightAnimation.stop()
        heightAnimation.to = 0
        heightAnimation.start()
    }

    function resize(): void {
        if (!overlay.visible || root.closing)
            return

        heightAnimation.stop()
        heightAnimation.to = root.desiredHeight
        heightAnimation.start()
    }

    function select(index): void {
        if (root.applications.length === 0) {
            root.selectedIndex = 0
            return
        }

        root.selectedIndex = Math.max(
            0,
            Math.min(root.applications.length - 1, index)
        )
        root.ensureSelectionVisible()
    }

    function ensureSelectionVisible(): void {
        if (root.applications.length === 0)
            return

        const selectedRow = Math.floor(root.selectedIndex / 2)
        const firstRow = Math.floor(resultGrid.contentY / root.rowHeight)
        const lastRow = firstRow + root.maximumVisibleRows - 1
        const maximumY = Math.max(
            0,
            resultGrid.contentHeight - resultGrid.height
        )

        if (selectedRow <= firstRow && firstRow > 0) {
            resultGrid.contentY = Math.max(
                0,
                (selectedRow - 1) * root.rowHeight
            )
        } else if (selectedRow >= lastRow && maximumY > 0) {
            resultGrid.contentY = Math.min(
                maximumY,
                (selectedRow - root.maximumVisibleRows + 2) * root.rowHeight
            )
        }
    }

    function launchSelected(): void {
        const application = root.applications[root.selectedIndex]
        if (application === undefined)
            return

        application.execute()
        root.close()
    }

    Connections {
        target: IpcManager

        function onLauncherOpenRequested(): void {
            root.open()
        }
    }

    NumberAnimation {
        id: heightAnimation

        target: root
        property: "launcherHeight"
        duration: 220
        easing.type: Easing.OutCubic

        onFinished: {
            if (!root.closing)
                return

            overlay.visible = false
            root.closing = false
            searchInput.text = ""
        }
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

        visible: false
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: visible
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-app-launcher"

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }

        Shape {
            id: launcherShape

            readonly property real popupLeft:
                (overlay.width - root.launcherWidth) / 2
            readonly property real popupRight: popupLeft + root.launcherWidth
            readonly property real popupTop: root.frameTop
            readonly property real popupBottom: popupTop + root.launcherHeight

            anchors.fill: parent

            ShapePath {
                fillColor: Theme[Config.colors.background]
                strokeWidth: -1

                startX: launcherShape.popupLeft
                startY: launcherShape.popupTop
                    - Config.borderWidth / 2

                PathLine {
                    x: launcherShape.popupRight
                    y: launcherShape.popupTop
                        - Config.borderWidth / 2
                }
                PathLine {
                    x: launcherShape.popupRight
                    y: launcherShape.popupBottom
                }
                PathLine {
                    x: launcherShape.popupLeft
                    y: launcherShape.popupBottom
                }
                PathLine {
                    x: launcherShape.popupLeft
                    y: launcherShape.popupTop
                        - Config.borderWidth / 2
                }
            }

            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme[Config.colors.border]
                strokeWidth: Config.borderWidth
                capStyle: ShapePath.FlatCap

                startX: launcherShape.popupLeft
                startY: launcherShape.popupTop

                PathLine {
                    x: launcherShape.popupLeft
                    y: launcherShape.popupBottom
                }
                PathLine {
                    x: launcherShape.popupRight
                    y: launcherShape.popupBottom
                }
                PathLine {
                    x: launcherShape.popupRight
                    y: launcherShape.popupTop
                }
            }
        }

        Item {
            id: launcherArea

            x: launcherShape.popupLeft
            y: root.frameTop
            width: root.launcherWidth
            height: root.launcherHeight
            clip: true

            MouseArea {
                anchors.fill: parent
            }

            Rectangle {
                id: inputBackground

                x: root.padding
                y: root.padding
                width: parent.width - root.padding * 2
                height: root.rowHeight
                color: Theme[Config.colors.surface]

                Item {
                    id: inputArea

                    anchors.fill: parent

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: root.padding
                            verticalCenter: parent.verticalCenter
                        }
                        visible: searchInput.text.length === 0
                        text: "Search applications"
                        color: Theme[Config.colors.muted]
                        font.family: "monospace"
                        font.bold: true
                        font.pixelSize: Config.fontSize
                    }

                    TextInput {
                        id: searchInput

                        anchors {
                            fill: parent
                            leftMargin: root.padding
                            rightMargin: root.padding
                        }
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme[Config.colors.foreground]
                        selectionColor: Theme[Config.colors.accent]
                        selectedTextColor: Theme[Config.colors.background]
                        font.family: "monospace"
                        font.bold: true
                        font.pixelSize: Config.fontSize
                        clip: true

                        onTextChanged: {
                            root.selectedIndex = 0
                            resultGrid.contentY = 0
                            Qt.callLater(() => root.resize())
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                root.close()
                            } else if (event.key === Qt.Key_Return
                                    || event.key === Qt.Key_Enter) {
                                root.launchSelected()
                            } else if (event.key === Qt.Key_Left) {
                                root.select(root.selectedIndex - 1)
                            } else if (event.key === Qt.Key_Right) {
                                root.select(root.selectedIndex + 1)
                            } else if (event.key === Qt.Key_Up) {
                                root.select(root.selectedIndex - 2)
                            } else if (event.key === Qt.Key_Down) {
                                root.select(root.selectedIndex + 2)
                            } else {
                                return
                            }

                            event.accepted = true
                        }
                    }
                }

            }

            Item {
                id: resultBackground

                x: root.padding
                y: inputBackground.y + inputBackground.height + root.padding
                width: parent.width - root.padding * 2
                height: root.resultHeight
                visible: height > 0
                clip: true

                GridView {
                    id: resultGrid

                    anchors.fill: parent
                    clip: true
                    interactive: contentHeight > height
                    boundsBehavior: Flickable.StopAtBounds
                    cellWidth: width / 2
                    cellHeight: root.rowHeight
                    model: root.applications
                    currentIndex: root.applications.length > 0
                        ? root.selectedIndex
                        : -1

                    delegate: Item {
                        id: applicationEntry

                        required property var modelData
                        required property int index

                        width: resultGrid.cellWidth
                        height: resultGrid.cellHeight

                        Rectangle {
                            anchors {
                                fill: parent
                                margins: root.padding / 4
                            }
                            color: applicationEntry.index === root.selectedIndex
                                ? Theme[Config.colors.accent]
                                : "transparent"

                            Text {
                                anchors {
                                    fill: parent
                                    leftMargin: root.padding
                                    rightMargin: root.padding
                                }
                                verticalAlignment: Text.AlignVCenter
                                text: applicationEntry.modelData.name
                                elide: Text.ElideRight
                                color: applicationEntry.index === root.selectedIndex
                                    ? Theme[Config.colors.background]
                                    : Theme[Config.colors.foreground]
                                font.family: "monospace"
                                font.bold: true
                                font.pixelSize: Config.fontSize
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedIndex = applicationEntry.index
                                root.launchSelected()
                            }
                        }
                    }

                    Controls.ScrollBar.vertical: Controls.ScrollBar {
                        policy: Controls.ScrollBar.AsNeeded
                    }
                }
            }
        }
    }
}
