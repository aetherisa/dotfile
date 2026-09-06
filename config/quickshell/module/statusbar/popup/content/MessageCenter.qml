import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs.global as Global

Scope {
    id: root

    required property ShellScreen screen

    readonly property int padding: Global.Config.statusbar.padding
    readonly property int unit: Global.Config.statusbar.popup.unit
    readonly property int entryHeight: unit
    readonly property int queueWidth: unit * 10
    property bool opened: false

    function open(): void {
        root.opened = true
    }

    function close(): void {
        root.opened = false
    }

    function urgencyTag(urgency): string {
        if (urgency === NotificationUrgency.Critical)
            return "CRT"
        if (urgency === NotificationUrgency.Low)
            return "INF"
        return "NOR"
    }

    function urgencyColor(urgency): color {
        if (urgency === NotificationUrgency.Critical)
            return Global.Theme.base08
        if (urgency === NotificationUrgency.Low)
            return Global.Theme.base0B
        return Global.Theme.base0A
    }

    function actionLabel(action): string {
        if (action.text.length > 0)
            return action.text
        if (action.identifier.length > 0 && action.identifier !== "default")
            return action.identifier.toUpperCase()
        return "OPEN"
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

        visible: root.opened
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-message-center"

        Rectangle {
            anchors.fill: parent

            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: "transparent"
                }

                GradientStop {
                    position: 1
                    color: Global.Theme.withAlpha(Global.Theme.base00, "e6")
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }

        ListView {
            id: messageQueue

            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
                topMargin: root.padding
                rightMargin: root.padding
                bottomMargin: root.padding
            }
            width: root.queueWidth
            spacing: 0
            clip: false
            boundsBehavior: Flickable.StopAtBounds
            interactive: false
            model: ScriptModel {
                values: [...Global.Notifications.unread]
                objectProp: "id"
            }

            removeDisplaced: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            delegate: Item {
                id: slot

                required property var modelData
                required property int index

                readonly property bool hasActions:
                    modelData.actions.length > 0
                readonly property bool hasControls:
                    modelData.hasInlineReply || hasActions
                property bool expanded: false
                property bool dismissing: false

                width: messageQueue.width
                height: root.entryHeight
                    + (expanded ? details.implicitHeight : 0)
                    + root.padding
                opacity: 1

                Behavior on height {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }

                NumberAnimation {
                    id: dismissAnimation

                    target: slot
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 180
                    easing.type: Easing.OutCubic

                    onFinished:
                        Global.Notifications.dismiss(slot.modelData)
                }

                MouseArea {
                    anchors {
                        fill: parent
                        bottomMargin: root.padding
                    }
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor

                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            if (!slot.dismissing) {
                                slot.dismissing = true
                                dismissAnimation.start()
                            }
                            return
                        }

                        if (!slot.dismissing)
                            slot.expanded = !slot.expanded
                    }
                }

                Row {
                    id: summary

                    width: slot.width
                    height: root.entryHeight
                    spacing: 0

                    Rectangle {
                        width: tagText.implicitWidth + 12
                        height: parent.height
                        color: root.urgencyColor(slot.modelData.urgency)

                        Text {
                            id: tagText

                            anchors.centerIn: parent
                            text: root.urgencyTag(slot.modelData.urgency)
                            color: Global.Theme.base00
                            font.family: "monospace"
                            font.bold: true
                            font.pixelSize: Global.Config.statusbar.fontSize
                        }
                    }

                    Rectangle {
                        width: summary.width - tagText.implicitWidth - 12
                        height: parent.height
                        color: Global.Theme[
                            Global.Config.statusbar.component.contentColor
                        ]

                        Text {
                            anchors {
                                fill: parent
                                leftMargin: root.padding
                                rightMargin: root.padding
                            }
                            verticalAlignment: Text.AlignVCenter
                            text: slot.modelData.summary
                                || slot.modelData.appName
                                || "Notification"
                            elide: Text.ElideRight
                            color: Global.Theme.base05
                            font.family: "monospace"
                            font.bold: true
                            font.pixelSize: Global.Config.statusbar.fontSize
                        }
                    }
                }

                Rectangle {
                    id: details

                    y: root.entryHeight
                    width: slot.width
                    readonly property int contentHeight:
                        detailText.implicitHeight
                        + (slot.hasControls
                            ? root.padding
                                + Global.Config.statusbar.height
                            : 0)
                    implicitHeight: contentHeight + root.padding * 2
                    height: slot.expanded ? implicitHeight : 0
                    color: Global.Theme[
                        Global.Config.statusbar.component.contentColor
                    ]
                    opacity: slot.expanded ? 1 : 0
                    enabled: slot.expanded
                    clip: true

                    Behavior on opacity {
                        NumberAnimation { duration: 180 }
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutCubic
                        }
                    }

                    Text {
                        id: detailText

                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: root.padding
                        }
                        text: slot.modelData.body
                            || slot.modelData.summary
                            || slot.modelData.appName
                            || "Notification"
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        color: Global.Theme.base05
                        font.family: "monospace"
                        font.bold: true
                        font.pixelSize: Global.Config.statusbar.fontSize
                    }

                    Item {
                        id: controls

                        anchors {
                            left: parent.left
                            right: parent.right
                            top: detailText.bottom
                            topMargin: root.padding
                            leftMargin: root.padding
                            rightMargin: root.padding
                        }
                        height: slot.hasControls
                            ? Global.Config.statusbar.height
                            : 0

                        Row {
                            anchors.fill: parent
                            visible: slot.hasActions
                                && !slot.modelData.hasInlineReply
                            spacing: root.padding

                            Repeater {
                                model: [...slot.modelData.actions]

                                Rectangle {
                                    id: actionButton

                                    required property var modelData

                                    width: Math.max(
                                        root.unit * 1.5,
                                        actionText.implicitWidth
                                            + root.padding * 2
                                    )
                                    height: parent.height
                                    color: actionMouse.containsMouse
                                        ? Global.Theme.base06
                                        : Global.Theme.base05

                                    Text {
                                        id: actionText

                                        anchors.centerIn: parent
                                        text: root.actionLabel(
                                            actionButton.modelData)
                                        color: Global.Theme.base00
                                        font.family: "monospace"
                                        font.bold: true
                                        font.pixelSize:
                                            Global.Config.statusbar.fontSize
                                    }

                                    MouseArea {
                                        id: actionMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            actionButton.modelData.invoke()
                                            slot.expanded = false
                                        }
                                    }
                                }
                            }
                        }

                        Row {
                            anchors.fill: parent
                            visible: slot.modelData.hasInlineReply
                            spacing: root.padding

                            Rectangle {
                                width: parent.width
                                    - submitButton.width
                                    - parent.spacing
                                height: parent.height
                                color: Global.Theme.base00

                                TextInput {
                                    id: replyInput

                                    anchors {
                                        fill: parent
                                        leftMargin: root.padding
                                        rightMargin: root.padding
                                    }
                                    verticalAlignment: TextInput.AlignVCenter
                                    clip: true
                                    color: Global.Theme.base05
                                    selectionColor: Global.Theme.base0D
                                    selectedTextColor: Global.Theme.base00
                                    font.family: "monospace"
                                    font.bold: true
                                    font.pixelSize:
                                        Global.Config.statusbar.fontSize

                                    Text {
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                        visible: replyInput.text.length === 0
                                            && !replyInput.activeFocus
                                        text: slot.modelData.inlineReplyPlaceholder
                                            || "Reply..."
                                        color: Global.Theme.base03
                                        font: replyInput.font
                                    }

                                    Keys.onReturnPressed:
                                        submitButton.submit()
                                }
                            }

                            Rectangle {
                                id: submitButton

                                width: root.unit * 1.5
                                height: parent.height
                                color: submitMouse.containsMouse
                                    ? Global.Theme.base06
                                    : Global.Theme.base05

                                function submit(): void {
                                    if (replyInput.text.length === 0)
                                        return

                                    slot.modelData.sendInlineReply(
                                        replyInput.text)
                                    replyInput.text = ""
                                    slot.expanded = false
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "SUB"
                                    color: Global.Theme.base00
                                    font.family: "monospace"
                                    font.bold: true
                                    font.pixelSize:
                                        Global.Config.statusbar.fontSize
                                }

                                MouseArea {
                                    id: submitMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: submitButton.submit()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
