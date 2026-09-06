import QtQuick
import Quickshell
import qs.global

Item {
    id: root

    readonly property int unit: Config.statusbar.popup.unit
    readonly property int rowHeight: unit

    implicitWidth: unit * 10
    implicitHeight: Math.max(root.rowHeight, streamColumn.implicitHeight)

    Rectangle {
        anchors.fill: parent
        color: Theme.base01
    }

    ScriptModel {
        id: streamModel

        values: [...Audio.streams]
        objectProp: "id"
    }

    Text {
        anchors.centerIn: parent
        visible: Audio.streams.length === 0
        text: "No playback streams"
        color: Theme.base03
        font.family: "monospace"
        font.bold: true
        font.pixelSize: Config.statusbar.fontSize
    }

    Column {
        id: streamColumn

        width: parent.width

        Repeater {
            model: streamModel

            Item {
                id: streamRow

                required property var modelData
                readonly property var audio: modelData.audio

                width: streamColumn.width
                height: root.rowHeight

                Text {
                    id: streamLabel

                    anchors {
                        left: parent.left
                        leftMargin: Config.statusbar.padding
                        verticalCenter: parent.verticalCenter
                    }
                    width: root.unit * 3
                    text: Audio.streamName(streamRow.modelData)
                    elide: Text.ElideRight
                    color: Theme.base05
                    font.family: "monospace"
                    font.bold: true
                    font.pixelSize: Config.statusbar.fontSize
                }

                Item {
                    id: volumeBar

                    anchors {
                        left: streamLabel.right
                        right: volumeText.left
                        leftMargin: Config.statusbar.padding
                        rightMargin: Config.statusbar.padding
                        verticalCenter: parent.verticalCenter
                    }
                    height: Config.statusbar.height / 2

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.base02
                    }

                    Rectangle {
                        width: parent.width * Math.max(
                            0,
                            Math.min(1, streamRow.audio.volume)
                        )
                        height: parent.height
                        color: streamRow.audio.muted
                            ? Theme.base03
                            : Theme[Config.statusbar.popup.color]
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        function updateVolume(mouseX): void {
                            Audio.setStreamVolume(
                                streamRow.modelData,
                                mouseX / width
                            )
                        }

                        onPressed: mouse => updateVolume(mouse.x)
                        onPositionChanged: mouse => {
                            if (pressed)
                                updateVolume(mouse.x)
                        }
                        onWheel: wheel => Audio.setStreamVolume(
                            streamRow.modelData,
                            streamRow.audio.volume
                                + (wheel.angleDelta.y > 0 ? 0.05 : -0.05)
                        )
                    }
                }

                Text {
                    id: volumeText

                    anchors {
                        right: parent.right
                        rightMargin: Config.statusbar.padding
                        verticalCenter: parent.verticalCenter
                    }
                    width: root.unit * 1.5
                    horizontalAlignment: Text.AlignRight
                    text: streamRow.audio.muted
                        ? "--"
                        : Math.round(streamRow.audio.volume * 100) + "%"
                    color: Theme.base05
                    font.family: "monospace"
                    font.bold: true
                    font.pixelSize: Config.statusbar.fontSize
                }
            }
        }
    }
}
