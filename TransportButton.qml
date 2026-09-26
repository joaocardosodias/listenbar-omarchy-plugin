import QtQuick
import qs.Commons

Item {
    id: root

    property string iconText: ""
    property color foreground: Color.foreground
    property color accent: Color.accent
    property real buttonSize: Style.space(24)

    signal clicked()

    implicitWidth: buttonSize
    implicitHeight: buttonSize
    opacity: enabled ? 1 : 0.32

    Rectangle {
        anchors.fill: parent
        radius: Style.cornerRadius
        color: mouse.containsMouse ? Style.hoverStateColor(root.foreground, root.accent) : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 100
            }

        }

    }

    Text {
        anchors.centerIn: parent
        text: root.iconText
        textFormat: Text.PlainText
        color: root.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.icon
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }

}
