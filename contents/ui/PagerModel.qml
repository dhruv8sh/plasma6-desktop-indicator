import QtQuick
import org.kde.plasma.private.pager

PagerModel {
    id: pagerModel
    enabled: true
    showDesktop: plasmoid.configuration.currentDesktopSelected == 1
    screenGeometry: plasmoid.containment.screenGeometry
    pagerType: PagerModel.VirtualDesktops
    onCurrentPageChanged: updateRepresentation()
    property int wheelDelta: 0
    property bool wrapOn: plasmoid.configuration.desktopWrapOn
    function wheelHandle(wheel) {
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
                const nextPage = wrapOn?(currentPage + 1) % pagerModel.count :
                    Math.min(currentPage + 1, pagerModel.count - 1);
                pagerModel.changePage(nextPage);
            } else {
                const previousPage = wrapOn ? (pagerModel.count + currentPage - 1) % pagerModel.count :
                    Math.max(currentPage - 1, 0);
                pagerModel.changePage(previousPage);
            }
            increment += (increment < 0) ? 1 : -1;
            wheelDelta = 0;
        }
    }
    function updateRepresentation() {
        var pos = currentPage
        var prev = ""
        for( var i = 0; i < count; i ++ ) {
            var item = repeater.itemAt(i/columnsAmount).get(i%columnsAmount);
            prev+=item.isActive?"x":"0"
            item.isActive = i == pos
        }
    }
}
