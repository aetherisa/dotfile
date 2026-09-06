import QtQuick
import Quickshell
import qs.global as Global

Item {
    id: root

    readonly property int unit: Global.Config.statusbar.popup.unit
    readonly property var player: Global.Media.activePlayer
    readonly property bool showPlayerSelector: Global.Media.players.length >= 2

    implicitWidth: unit * 10
    implicitHeight: unit * (showPlayerSelector ? 5 : 4)

    Rectangle {
        anchors.fill: parent
        color: Global.Theme.base01
    }

    ListView {
        id: playerList

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: root.showPlayerSelector ? root.unit : 0
        visible: root.showPlayerSelector
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        model: ScriptModel {
            values: Global.Media.players
            objectProp: "dbusName"
        }

        delegate: Rectangle {
            id: playerButton

            required property var modelData
            readonly property bool selected:
                modelData === Global.Media.activePlayer

            width: Math.max(root.unit * 2, playerName.implicitWidth + 24)
            height: playerList.height
            color: selected
                ? Global.Theme.base05
                : playerMouse.containsMouse
                    ? Global.Theme.base06
                    : Global.Theme.base02

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Text {
                id: playerName

                anchors.centerIn: parent
                text: playerButton.modelData.identity || "Player"
                color: playerButton.selected || playerMouse.containsMouse
                    ? Global.Theme.base00
                    : Global.Theme.base05
                font.family: "monospace"
                font.bold: true
                font.pixelSize: Global.Config.statusbar.fontSize
            }

            MouseArea {
                id: playerMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Global.Media.select(playerButton.modelData)
            }
        }
    }

    Item {
        id: metadata

        anchors {
            left: parent.left
            right: parent.right
            top: playerList.bottom
        }
        height: root.unit * 1.5

        Text {
            id: titleText

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: Global.Config.statusbar.padding
                rightMargin: Global.Config.statusbar.padding
            }
            height: root.unit * 0.75
            verticalAlignment: Text.AlignBottom
            text: root.player?.trackTitle || "Nothing playing"
            elide: Text.ElideRight
            color: Global.Theme.base05
            font.family: "monospace"
            font.bold: true
            font.pixelSize: Global.Config.statusbar.fontSize
        }

        Text {
            anchors {
                left: parent.left
                right: parent.right
                top: titleText.bottom
                leftMargin: Global.Config.statusbar.padding
                rightMargin: Global.Config.statusbar.padding
            }
            height: root.unit * 0.75
            verticalAlignment: Text.AlignTop
            text: root.player?.trackArtist || root.player?.identity || "--"
            elide: Text.ElideRight
            color: Global.Theme.base03
            font.family: "monospace"
            font.bold: true
            font.pixelSize: Global.Config.statusbar.fontSize
        }
    }

    Item {
        id: progressRow

        anchors {
            left: parent.left
            right: parent.right
            top: metadata.bottom
        }
        height: root.unit

        Text {
            id: elapsedText

            anchors {
                left: parent.left
                leftMargin: Global.Config.statusbar.padding
                verticalCenter: parent.verticalCenter
            }
            width: root.unit * 1.5
            text: Global.Media.available
                ? Global.Media.formatTime(Global.Media.position)
                : "--"
            color: Global.Theme.base05
            font.family: "monospace"
            font.bold: true
            font.pixelSize: Global.Config.statusbar.fontSize
        }

        Item {
            id: progressBar

            anchors {
                left: elapsedText.right
                right: durationText.left
                leftMargin: Global.Config.statusbar.padding
                rightMargin: Global.Config.statusbar.padding
                verticalCenter: parent.verticalCenter
            }
            height: Global.Config.statusbar.height / 2

            Rectangle {
                anchors.fill: parent
                color: Global.Theme.base02
            }

            Rectangle {
                width: parent.width * (Global.Media.length > 0
                    ? Math.max(0, Math.min(1,
                        Global.Media.position / Global.Media.length))
                    : 0)
                height: parent.height
                color: Global.Theme[Global.Config.statusbar.popup.color]
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.player?.canSeek ?? false
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                function updatePosition(mouseX): void {
                    Global.Media.seek(mouseX / width)
                }

                onPressed: mouse => updatePosition(mouse.x)
                onPositionChanged: mouse => {
                    if (pressed)
                        updatePosition(mouse.x)
                }
            }
        }

        Text {
            id: durationText

            anchors {
                right: parent.right
                rightMargin: Global.Config.statusbar.padding
                verticalCenter: parent.verticalCenter
            }
            width: root.unit * 1.5
            horizontalAlignment: Text.AlignRight
            text: Global.Media.length > 0
                ? Global.Media.formatTime(Global.Media.length)
                : "--"
            color: Global.Theme.base05
            font.family: "monospace"
            font.bold: true
            font.pixelSize: Global.Config.statusbar.fontSize
        }
    }

    Row {
        id: controls

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
        height: root.unit * 1.5
        spacing: Global.Config.statusbar.padding

        Repeater {
            model: ["PRE", Global.Media.playing ? "PAU" : "PLY", "NXT"]

            Rectangle {
                id: controlButton

                required property string modelData
                readonly property bool enabledAction:
                    modelData === "PRE"
                    ? root.player?.canGoPrevious ?? false
                    : modelData === "NXT"
                        ? root.player?.canGoNext ?? false
                        : root.player?.canTogglePlaying ?? false

                width: root.unit * 2
                height: root.unit
                anchors.verticalCenter: parent.verticalCenter
                color: controlMouse.containsMouse && enabledAction
                    ? Global.Theme.base06
                    : Global.Theme.base05
                opacity: enabledAction ? 1 : 0.45

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    anchors.centerIn: parent
                    text: controlButton.modelData
                    color: Global.Theme.base00
                    font.family: "monospace"
                    font.bold: true
                    font.pixelSize: Global.Config.statusbar.fontSize
                }

                MouseArea {
                    id: controlMouse

                    anchors.fill: parent
                    enabled: controlButton.enabledAction
                    hoverEnabled: true
                    cursorShape: enabled
                        ? Qt.PointingHandCursor
                        : Qt.ArrowCursor
                    onClicked: {
                        if (controlButton.modelData === "PRE")
                            Global.Media.previous()
                        else if (controlButton.modelData === "NXT")
                            Global.Media.next()
                        else
                            Global.Media.toggle()
                    }
                }
            }
        }
    }
}
