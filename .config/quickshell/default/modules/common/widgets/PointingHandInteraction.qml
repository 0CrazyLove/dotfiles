import QtQuick
import "../../../colors.qml" as Colors

MouseArea {
    anchors.fill: parent
    onPressed: (mouse) => mouse.accepted = false
    cursorShape: Qt.PointingHandCursor 
}