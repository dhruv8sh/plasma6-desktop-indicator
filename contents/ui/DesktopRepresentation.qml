import QtQuick
import org.kde.plasma.components
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
// import QtQml.Models
// import org.kde.taskmanager as TaskManager

Rectangle {
    id: container
    z: 5
    height: plasmoid.configuration.dotSizeCustom
    width: plasmoid.configuration.dotSizeCustom
    property int pos
    property bool boldOnActive: plasmoid.configuration.boldOnActive
    property bool italicOnActive: plasmoid.configuration.italicOnActive
    property bool highlightOnActive: plasmoid.configuration.highlightOnActive
    property bool isAddButton: false
    property bool isActive: false
    opacity: isAddButton ? 0.5: 1

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
        visible: isAddButton
        radius: (rect.height / 2)*plasmoid.configuration.radiusFactor
    }
    // TaskManager.ActivityInfo {
    //     id: activityInfo
    // }
    // TaskManager.TasksModel {
    //     id: taskmanager
    //     sortMode: TaskManager.TasksModel.SortVirtualDesktop
    //     groupMode: TaskManager.TasksModel.GroupDisabled
    //     // screenGeometry: plasmoid.screenGeometry
    //     activity: activityInfo.currentActivity
    //     virtualDesktop: pos
    //     // filterByScreen: plasmoid.configuration.filterByScreen
    //     filterByVirtualDesktop: true
    //     filterByActivity: true
    // }
    Label {
        id: label
        anchors.centerIn: parent
        font.bold: isActive && boldOnActive
        font.italic: isActive && italicOnActive
        font.pixelSize: Plasmoid.configuration.dotSizeCustom + (isAddButton ? 2 : 0)
        text: {
            if( isAddButton ) return '+'
            else return indicatorType == 1 ? pos+1 : plasmoid.configuration.inactiveText
        }
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
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: isAddButton ? pagerModel.addDesktop() : pagerModel.changePage(pos)
        onContainsMouseChanged: container.opacity = containsMouse || isAddButton ? 0.5 : 1
    }
    function activate(yes, to) {
        isActive = yes
        if( isAddButton ) label.text = '+'
        else if( indicatorType == 0 ) label.text = yes ? plasmoid.configuration.activeText : plasmoid.configuration.inactiveText;
        else label.text = pos+1;
        rect.visible = yes && highlightOnActive
        z = yes ? 2 : 1
        // console.log( "Windows open on desktop "+pos+": "+taskmanager.tasks[0])
        // if( plasmoid.configuration.showOnlyWithWindows ) console.log( "Windows open on desktop "+pos+": "+taskmanager.count);
    }
}
