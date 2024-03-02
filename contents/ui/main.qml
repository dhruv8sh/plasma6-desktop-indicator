import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.pager

PlasmoidItem {

    id: root

    preferredRepresentation: fullRepresentation

    GridLayout {
        id: grid
        anchors.centerIn : parent
        // padding: 3
        columnSpacing: plasmoid.configuration.spacingHorizontal/2
        rowSpacing: plasmoid.configuration.spacingVertical/2
        columns: {
            var columns = 1;
            if( isSingleRow ) columns = isHorizontal?pagerModel.count:1;
            else columns = isHorizontal?Math.ceil(pagerModel.count/pagerModel.layoutRows):pagerModel.layoutRows;
            return columns;
        }
        rows: {
            let rows = 1;
            if( isSingleRow ) rows = isHorizontal ? 1 : pagerModel.count;
            else rows = isHorizontal ? pagerModel.layoutRows : Math.ceil(pagerModel.count/pagerModel.layoutRows);
            return rows;
        }
        Repeater {
            id: repeater
            model: pagerModel.count
            DesktopRepresentation { pos: index }
            onCountChanged: root.updateRepresentation()
        }
    }

    property int wheelDelta: 0
    property bool isHorizontal: plasmoid.formFactor != PlasmaCore.Types.Vertical
    property bool isSingleRow: plasmoid.configuration.singleRow
    property bool wrapOn: plasmoid.configuration.desktopWrapOn

    anchors.centerIn: parent
    anchors.fill: parent
    Layout.minimumWidth: grid.implicitWidth
    Layout.minimumHeight: grid.implicitHeight

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
                    const nextPage = wrapOn? (pagerModel.currentPage + 1) % repeater.count :
                        Math.min(pagerModel.currentPage + 1, repeater.count - 1);
                    pagerModel.changePage(nextPage);
                } else {
                    const previousPage = wrapOn ? (repeater.count + pagerModel.currentPage - 1) % repeater.count :
                        Math.max(pagerModel.currentPage - 1, 0);
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
        id: executable
        engine: "executable"
        connectedSources: []
        function exec(cmd) {
            executable.connectSource(cmd)
        }
        onConnectedSourcesChanged: {
            if (connectedSources.length > 0) {
                var cmd = connectedSources.shift()
                executable.connectSource(cmd)
            }
        }
    }
    function updateRepresentation() {
        var pos = pagerModel.currentPage
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
}
