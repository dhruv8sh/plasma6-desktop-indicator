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
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape:Qt.PointingHandCursor
        onClicked:pagerModel.changePage(pos)
    }
    function activate(yes, to) {
        label.font.bold= yes && boldOnActive;
        label.font.italic= yes && italicOnActive;
        label.color= yes && highlightOnActive ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
        if( indicatorType == 0 ) {
            label.text = yes ? plasmoid.configuration.activeText : plasmoid.configuration.inactiveText;
        } else {
            label.text = pos+1;
        }
        rect.visible = yes && highlightOnActive;
        // console.log( "Windows open on desktop "+pos+": "+taskmanager.tasks[0])
        // if( plasmoid.configuration.showOnlyWithWindows ) console.log( "Windows open on desktop "+pos+": "+taskmanager.count);
        container.visible = yes || !plasmoid.configuration.showOnlyWithWindows || taskmanager.count > 0
    }
}
