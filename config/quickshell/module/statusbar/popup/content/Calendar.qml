import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import qs.global

Item {
    id: root

    property date currentDate: new Date()
    property int displayedMonth: currentDate.getMonth()
    property int displayedYear: currentDate.getFullYear()

    readonly property int cellSize: Config.statusbar.calendar.headerHeight
    readonly property int headerHeight: Config.statusbar.calendar.headerHeight
    readonly property int weekHeaderHeight:
        Config.statusbar.calendar.weekHeaderHeight

    implicitWidth: cellSize * 7
    implicitHeight:
        headerHeight
        + weekHeaderHeight
        + cellSize * 6

    function changeMonth(offset: int): void {
        const date = new Date(
            root.displayedYear,
            root.displayedMonth + offset,
            1
        )

        root.displayedMonth = date.getMonth()
        root.displayedYear = date.getFullYear()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.base01
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.minimumHeight: root.headerHeight
            Layout.preferredHeight: root.headerHeight
            Layout.maximumHeight: root.headerHeight

            RowLayout {
                anchors.fill: parent
                spacing: 8

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        anchors.centerIn: parent

                        text: "<"
                        font.bold: true
                        font.pixelSize: Config.statusbar.fontSize
                        color: previousMouse.containsMouse
                            ? Theme.base0B
                            : Theme.base05

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }
                    }

                    MouseArea {
                        id: previousMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.changeMonth(-1)
                    }
                }

                Text {
                    text: monthGrid.title
                    color: Theme.base05
                    font.bold: true
                    font.family: "monospace"
                    font.pixelSize: Config.statusbar.fontSize
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        anchors.centerIn: parent

                        text: ">"
                        font.bold: true
                        font.pixelSize: Config.statusbar.fontSize
                        color: nextMouse.containsMouse
                            ? Theme.base0B
                            : Theme.base05

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }
                    }

                    MouseArea {
                        id: nextMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.changeMonth(1)
                    }
                }
            }
        }

        Controls.DayOfWeekRow {
            id: weekHeader

            Layout.fillWidth: true
            Layout.minimumHeight: root.weekHeaderHeight
            Layout.preferredHeight: root.weekHeaderHeight
            Layout.maximumHeight: root.weekHeaderHeight
            locale: monthGrid.locale

            delegate: Text {
                required property string narrowName

                text: narrowName
                color: Theme.base03
                font.family: "monospace"
                font.bold: true
                font.pixelSize: Config.statusbar.fontSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Controls.MonthGrid {
            id: monthGrid

            Layout.fillWidth: true
            Layout.minimumHeight: root.cellSize * 6
            Layout.preferredHeight: root.cellSize * 6
            Layout.maximumHeight: root.cellSize * 6

            month: root.displayedMonth
            year: root.displayedYear
            locale: Qt.locale()

            delegate: Rectangle {
                required property var model

                color: model.today
                    ? Theme[Config.statusbar.calendar.color]
                    : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: model.day
                    color: model.month === monthGrid.month
                        ? model.today
                        ? Theme.base00
                        : Theme.base05
                        : Theme.base03
                    opacity:
                    model.month === monthGrid.month ? 1 : 0.4
                    font.family: "monospace"
                    font.bold: model.today
                    font.pixelSize: Config.statusbar.fontSize
                }
            }
        }
    }
}
