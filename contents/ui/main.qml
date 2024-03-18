import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.pager
import org.kde.kcmutils as KCM
import org.kde.config as KConfig

PlasmoidItem {

    id: root
    preferredRepresentation: fullRepresentation
    property alias current: pagerModel.currentPage
    property int wheelDelta: 0
    property bool isHorizontal: plasmoid.formFactor != PlasmaCore.Types.Vertical
    property bool isSingleRow: plasmoid.configuration.singleRow
    property bool wrapOn: plasmoid.configuration.desktopWrapOn
    property int addDesktop: plasmoid.configuration.showAddDesktop && isSingleRow ? 1 : 0

    GridLayout {
        id: grid
        anchors.centerIn : parent
        // padding: 3
        columnSpacing: plasmoid.configuration.spacingHorizontal/2
        rowSpacing: plasmoid.configuration.spacingVertical/2
        columns: {
            var columns = 1;
            if( isSingleRow ) columns = isHorizontal?pagerModel.count+addDesktop : 1;
            else columns = isHorizontal?Math.ceil(pagerModel.count/pagerModel.layoutRows):pagerModel.layoutRows;
            return columns;
        }
        rows: {
            let rows = 1;
            if( isSingleRow ) rows = isHorizontal ? 1 : pagerModel.count+addDesktop;
            else rows = isHorizontal ? pagerModel.layoutRows : Math.ceil(pagerModel.count/pagerModel.layoutRows);
            return rows;
        }
        Repeater {
            id: repeater
            model: pagerModel.count + addDesktop
            DesktopRepresentation {
                pos: index
                isAddButton: addDesktop === 1 && index === pagerModel.count
            }
            onCountChanged: root.updateRepresentation()
        }
    }


    anchors.centerIn: parent
    anchors.fill: parent
    Layout.minimumWidth: grid.implicitWidth + plasmoid.configuration.spacingHorizontal
    Layout.minimumHeight: grid.implicitHeight + plasmoid.configuration.spacingVertical

    PagerModel {
        id: pagerModel
        enabled: true
        showDesktop: plasmoid.configuration.currentDesktopSelected == 1
        screenGeometry: plasmoid.containment.screenGeometry
        pagerType: PagerModel.VirtualDesktops
        onCurrentPageChanged: updateRepresentation()
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton
        onClicked: perform( Plasmoid.configuration.middleButtonCommand )
        onWheel : wheel => {
            wheelDelta += wheel.angleDelta.y || wheel.angleDelta.x;
            let increment = 0;
            while (wheelDelta >= 120) {
                wheelDelta -= 120;
                increment++;
            }
            while (wheelDelta <= -120) {
                wheelDelta += 120;
                increment--;
            }
            while (increment !== 0) {
                if (increment < 0) {
                    const nextPage = wrapOn? (current + 1) % pagerModel.count :
                        Math.min(current + 1, pagerModel.count - 1);
                    pagerModel.changePage(nextPage);
                } else {
                    const previousPage = wrapOn ? (pagerModel.count + current - 1) % pagerModel.count :
                        Math.max(current - 1, 0);
                    pagerModel.changePage(previousPage);
                }

                increment += (increment < 0) ? 1 : -1;
                wheelDelta = 0;
            }
        }
    }
    function perform(input) {
        executable.exec('qdbus org.kde.kglobalaccel /component/kwin invokeShortcut \"'+input+'\"')
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
            // console.log(data+" received after running "+ sourceName)
            disconnectSource(sourceName)
        }
        function exec(cmd) {
            connectSource(cmd)
        }
    }

    function updateRepresentation() {
        var pos = current
        for( var i = 0; i < repeater.count; i ++ ) {
            var item = repeater.itemAt(i);
            if (item ) {
                if( i == pos ){
                    item.activate(true, i);
                }
                else item.activate(false, i);
            } else {
                console.error("Item or label is undefined at index " + i);
            }
        }
        grid.anchors.centerIn = root
    }
    onIsHorizontalChanged : updateRepresentation()
    onIsSingleRowChanged: updateRepresentation()
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Add Virtual Desktop")
            icon.name: "list-add"
            visible: !root.isActivityPager && KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: pagerModel.addDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Remove Virtual Desktop")
            icon.name: "list-remove"
            visible: !root.isActivityPager && KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            enabled: repeater.count > 1
            onTriggered: pagerModel.removeDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Configure Virtual Desktops…")
            visible: !root.isActivityPager && KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: KCM.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops")
        }
    ]
}
