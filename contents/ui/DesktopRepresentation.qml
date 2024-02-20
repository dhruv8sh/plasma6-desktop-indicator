import QtQuick
import org.kde.plasma.components
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Rectangle {
    z: 5
    height: 10
    width: 10
    property int pos
    color: "transparent"
    // property activeText: plasmoid.configuration.activeText

    Label {
        font.pixelSize: Plasmoid.configuration.dotSizeCustom
        id: label
        anchors.centerIn: parent
        text: plasmoid.configuration.inactiveText
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
        onClicked:pagerModel.changePage(index)
    }
    function activate(yes) {
        label.text = yes ? plasmoid.configuration.activeText : plasmoid.configuration.inactiveText;
    }
}
