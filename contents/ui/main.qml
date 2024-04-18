import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents
import org.kde.plasma.private.pager 2.0

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    property bool isHorizontal: plasmoid.formFactor != PlasmaCore.Types.Vertical
    property bool isSingleRow: plasmoid.configuration.singleRow
    property int addDesktop: plasmoid.configuration.showAddDesktop && isSingleRow ? 1 : 0

    property int rowsAmount: {
        if( isSingleRow ) return isHorizontal ? 1 : pagerModel.count+addDesktop;
        else return isHorizontal ? pagerModel.layoutRows : Math.ceil(pagerModel.count/pagerModel.layoutRows);
    }
    property int columnsAmount: {
        if( isSingleRow ) return isHorizontal?pagerModel.count+addDesktop : 1;
        else return isHorizontal?Math.ceil(pagerModel.count/pagerModel.layoutRows):pagerModel.layoutRows;
    }
    columns: {
        if (Plasmoid.configuration.singleRow) {
            return pagerModel.count;
        } else {
            return Math.ceil(pagerModel.count / pagerModel.layoutRows);
        }
    }
    columnSpacing: 0
    rowSpacing: 0
    PagerModel {
        id: pagerModel
    }
    // RowLayout {
    //     id: grid
    //     anchors.centerIn : parent
    //     columnSpacing: plasmoid.configuration.spacingHorizontal
    //     rowSpacing: plasmoid.configuration.spacingVertical
    //
    //     rows:
    //     Repeater {
    //         id: repeater
    //         model: pagerModel.count + addDesktop
    //         DesktopRepresentation {
    //             required property int index
    //             pos: index
    //             isAddButton: addDesktop === 1 && index === pagerModel.count
    //         }
    //         onCountChanged: pagerModel.updateRepresentation()
    //     }
    //     Repeater {
    //         ColumnLayout {
    //             Repeater {
    //
    //             }
    //         }
    //     }
    // }

    ColumnLayout{
        id: columns
        // rows:rowsAmount
        Layout.fillHeight: isHorizontal
        Layout.fillWidth: true
        Repeater{
            id: repeater
            model:rowsAmount
            RowLayout{
                function get(a){
                    return innerRepeater.itemAt(a)
                }
                Layout.fillWidth: true
                // colums:columnsAmount
                property int a: index
                Repeater{
                    id: innerRepeater
                    model: a == rowsAmount-1 && a != 0 ? (columnsAmount*rowsAmount)-pagerModel.count : columnsAmount
                    DesktopRepresentation {
                        required property int index
                        pos: (a*columnsAmount)+index
                        isAddButton: addDesktop === 1 && index === pagerModel.count
                    }
                }
            }
        }
    }
    Layout.minimumWidth: columns.implicitWidth + plasmoid.configuration.spacingHorizontal
    Layout.minimumHeight: columns.implicitHeight + plasmoid.configuration.spacingVertical
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton
        onClicked: executable.middleClicked()
        onWheel : wheel => pagerModel.wheelHandle(wheel)
    }

    Plasma5Support.DataSource {
        id: "executable"
        engine: "executable"
        connectedSources: []
        onNewData:function(sourceName, data){
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            disconnectSource(sourceName)
        }
        function middleClicked() {
            connectSource('qdbus org.kde.kglobalaccel /component/kwin invokeShortcut \"'+ Plasmoid.configuration.middleButtonCommand+'\"')
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Add Virtual Desktop")
            icon.name: "list-add"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: pagerModel.addDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Remove Virtual Desktop")
            icon.name: "list-remove"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            enabled: pagerModel.count > 1
            onTriggered: pagerModel.removeDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Configure Virtual Desktops…")
            icon.name: "configure"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: KCM.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops")
        }
    ]
}
