import QtQuick
import org.kde.plasma.components
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "./Util.js" as Util

MouseArea {
    id: cont

    required property bool isAddButton
    required property int pos
    property bool isActive: false
    opacity: 1

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    onClicked: isAddButton ? pagerModel.addDesktop() : pagerModel.changePage(pos)
    onContainsMouseChanged: opacity = containsMouse || isAddButton ? 0.5 : 1
    height: plasmoid.configuration.dotSizeCustom
    width: label.width

    NumberAnimation {
        id: fadeAnim
        target: cont
        property: "opacity"
        from: 0.2
        to: 1
        duration: 500
        running: false
    }

    states: [
        State {
            name: "addButton"
            when: isAddButton
            PropertyChanges{
                target: label
                text: "+"
                opacity: 0.5
            }
        },
        State {
            name: "active0"
            when: isActive && plasmoid.configuration.indicatorType == 0
            PropertyChanges{
                target: label
                text: plasmoid.configuration.activeText
                font.bold: plasmoid.configuration.boldOnActive
                font.italic: plasmoid.configuration.italicOnActive
                z: 5
            }
            PropertyChanges{
                target: rect
                visible: plasmoid.configuration.highlightOnActive
            }
        },
        State {
            name: "inactive0"
            when: !isActive && plasmoid.configuration.indicatorType == 0
            PropertyChanges{
                target: label
                z: 0
                text: plasmoid.configuration.inactiveText
            }
            PropertyChanges{
                target: rect
                visible: false
            }
        },
        State {
            name: "inactive1"
            when: !isActive && plasmoid.configuration.indicatorType == 1
            extend: "inactive0"
            PropertyChanges{
                target: label
                text: pos+1
            }
        },
        State {
            name: "active1"
            when: isActive && plasmoid.configuration.indicatorType == 1
            extend: "active0"
            PropertyChanges{
                target: label
                text: pos+1
            }
        },
        State {
            name: "inactive2"
            when: !isActive && plasmoid.configuration.indicatorType == 2
            extend: "inactive0"
            PropertyChanges{
                target: label
                text: Util.numToRoman(pos+1)
            }
        },
        State {
            name: "active2"
            when: isActive && plasmoid.configuration.indicatorType == 2
            extend: "active0"
            PropertyChanges{
                target: label
                text: Util.numToRoman(pos+1)
            }
        }
    ]
    Label {
        id: label
        textFormat: Text.RichText
        onTextChanged: fadeAnim.running = true
        anchors.centerIn: parent
        verticalAlignment: Text.AlignVCenter
    }
    Rectangle{
        id: rect
        height: parent.height + 2*plasmoid.configuration.spacingVertical
        width : parent.width  + 2*plasmoid.configuration.spacingHorizontal
        anchors.centerIn: parent
        color: Kirigami.Theme.highlightColor
        radius: (rect.height/2)*plasmoid.configuration.radiusFactor
        visible: false
    }
}
