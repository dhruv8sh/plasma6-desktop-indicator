import QtQuick
import org.kde.plasma.components
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Rectangle {
    id: container
    z: 5
    height: plasmoid.configuration.dotSizeCustom
    width: plasmoid.configuration.dotSizeCustom
    property int pos
    property bool boldOnActive: plasmoid.configuration.boldOnActive
    property bool italicOnActive: plasmoid.configuration.italicOnActive
    property bool highlightOnActive: plasmoid.configuration.highlightOnActive

    // 0 : Text
    // 1 : Numbered
    property int indicatorType: plasmoid.configuration.indicatorType

    color: "transparent"
    Rectangle{
        id: rect
        height: parent.height + plasmoid.configuration.spacingVertical
        width: parent.width + plasmoid.configuration.spacingHorizontal
        anchors.centerIn: parent
        color: Kirigami.Theme.highlightColor
        radius: rect.height / 2
    }
    Label {
        font.pixelSize: Plasmoid.configuration.dotSizeCustom
        id: label
        anchors.centerIn: parent
        text: indicatorType == 1 ? pos+1 : plasmoid.configuration.inactiveText
        onTextChanged: function(text) {
            if( text == plasmoid.configuration.activeText )
                fadeAnimation.running = true
        }
        NumberAnimation {
            id: fadeAnimation
            target: label
            property: "opacity"
            from: 1.0
            to: 0.5
            duration: 500
            running: false
            onStopped: label.opacity = 1.0
        }
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked:pagerModel.changePage(pos)
    }
    function activate(yes, to) {
        label.font.bold= yes && boldOnActive;
        label.font.italic= yes && italicOnActive;
        if( indicatorType == 0 ) {
            label.text = yes ? plasmoid.configuration.activeText : plasmoid.configuration.inactiveText;
        } else {
            label.text = pos+1;
        }
        rect.visible = yes && highlightOnActive;
    }
}
