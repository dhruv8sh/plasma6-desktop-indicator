import QtQuick
import QtQuick.Controls as QC2
import QtQuick.Layouts as QtLayouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

Kirigami.ScrollablePage {
    id: generalPage

    signal configurationChanged

    property alias cfg_leftClickAction: leftClickAction.currentIndex
    property alias cfg_rightClickAction: rightClickAction.currentIndex
    property alias cfg_scrollWheelOn: scrollWheelOn.checked

    property alias cfg_desktopWrapOn: desktopWrapOn.checked
    property alias cfg_singleRow: singleRow.checked

    property alias cfg_dotSize: dotSize.currentIndex
    property alias cfg_dotSizeCustom: dotSizeCustom.value

    property alias cfg_dotType: dotType.currentIndex
    property alias cfg_activeDot: activeDot.text
    property alias cfg_inactiveDot: inactiveDot.text

    Kirigami.FormLayout {
        QtLayouts.Layout.fillWidth: true
        
        QtLayouts.RowLayout {
            Kirigami.FormData.label: i18n("Left click action:")
            
            QC2.ComboBox {
                id: leftClickAction
                model: [
                    i18n("Do nothing"),
                    i18n("Switch to next desktop"),
                    i18n("Switch to previous desktop"),
                    i18n("Go to clicked desktop"),
                    i18n("Show desktop overview"),
                ]
                onActivated: cfg_leftClickAction = currentIndex
            }
        }
        
        QtLayouts.RowLayout {
            Kirigami.FormData.label: i18n("Right click action:")
            
            QC2.ComboBox {
                id: rightClickAction
                model: [
                    i18n("Do nothing"),
                    i18n("Switch to next desktop"),
                    i18n("Switch to previous desktop"),
                    i18n("Show desktop overview"),
                ]
                onActivated: cfg_rightClickAction = currentIndex
                enabled: leftClickAction.currentIndex != 3 
            }
        }

        QC2.CheckBox {
            id: scrollWheelOn
            text: i18n("Scrollwheel switches desktops")
        }
    
        Item {
            Kirigami.FormData.isSection: true
        }

        QtLayouts.ColumnLayout {
            Kirigami.FormData.label: i18n("Navigation behaviour:")
            Kirigami.FormData.buddyFor: desktopWrapOff

            QC2.RadioButton {
                id: desktopWrapOff
                text: i18n("Standard")
            }

            QC2.RadioButton {
                id: desktopWrapOn
                text: i18n("Wraparound")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QtLayouts.ColumnLayout {
            Kirigami.FormData.label: i18n("Desktop Rows:")
            Kirigami.FormData.buddyFor: singleRow

            QC2.RadioButton {
                id: singleRow
                text: i18n("Single row")
            }

            QC2.RadioButton {
                id: multiRow
                text: i18n("Follow Plasma setting")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QtLayouts.RowLayout {
            Kirigami.FormData.label: i18n("Indicator Dot Size:")

            QC2.ComboBox {
                id: dotSize
                model: [
                    i18n("Default"),
                    i18n("Scale with panel size"),
                    i18n("Custom Size")
                ]
            }

            QC2.SpinBox {
                id: dotSizeCustom
                textFromValue: function(value) {
                    return i18n("%1 px", value)
                }
                valueFromText: function(text) {
                    return parseInt(text)
                }
                from: PlasmaCore.Theme.defaultFont.pixelSize
                to: 72
            }
        }
        QtLayouts.RowLayout {
            Kirigami.FormData.label: i18n("Horizontal Spacing:")

            QC2.SpinBox {
                id: spacingHorizontal
                textFromValue: function(value) {
                    return i18n("%1 px", value)
                }
                from: 0
                to: 500
            }
        }
        QtLayouts.RowLayout {
            Kirigami.FormData.label: i18n("Vertical Spacing:")

            QC2.SpinBox {
                id: spacingVertical
                textFromValue: function(value) {
                    return i18n("%1 px", value)
                }
                from: 0
                to: 30
            }
        }

        QtLayouts.GridLayout {
            id: dotCharGrid
            columns: 3
            QtLayouts.Layout.fillWidth: true

            Kirigami.FormData.label: i18n("Indicator Dot Type:")
            Kirigami.FormData.buddyFor: dotType
    
            QC2.ComboBox {
                id: dotType
                model: [
                    i18n("Custom"),
                    i18n("Desktop Numbers"),
                    i18n("Roman Numbers")
                ]
                onActivated: cfg_dotType = currentIndex
            }

            QC2.Label {
                text: i18n("Active Dot:")
                QtLayouts.Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                visible: dotType.currentIndex == 1
            }

            QC2.TextField {
                id: activeDot
                // QtLayouts.Layout.maximumWidth: 35
                maximumLength: 20
                text: Plasmoid.configuration.activeDot
                horizontalAlignment: TextInput.AlignHCenter
                visible: indicatorType.currentIndex == 0
                onTextChanged: {
                    var newText = "";
                    for (var i = 0; i < text.length; ++i) {
                        if (text.charCodeAt(i) >= 0xD800 && text.charCodeAt(i) <= 0xDBFF) {
                            if (i + 1 < text.length && text.charCodeAt(i + 1) >= 0xDC00 && text.charCodeAt(i + 1) <= 0xDFFF) {
                                newText += text[i] + text[i + 1];
                                i++;
                            } else { }
                        } else {
                            newText += text[i];
                        }
                    }
                    text = newText;
                }
            }        

            Item {
                width: 5
            }
        
            QC2.Label {
                text: i18n("Inactive Dot:")
                QtLayouts.Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                visible: dotType.currentIndex == 1
            }

            QC2.TextField {
                id: inactiveDot
                // QtLayouts.Layout.maximumWidth: 35
                maximumLength: 20
                text: Plasmoid.configuration.inactiveDot
                horizontalAlignment: TextInput.AlignHCenter
                visible: indicatorType.currentIndex == 0
                onTextChanged: {
                    var newText = "";
                    for (var i = 0; i < text.length; ++i) {
                        if (text.charCodeAt(i) >= 0xD800 && text.charCodeAt(i) <= 0xDBFF) {
                            if (i + 1 < text.length && text.charCodeAt(i + 1) >= 0xDC00 && text.charCodeAt(i + 1) <= 0xDFFF) {
                                newText += text[i] + text[i + 1];
                                i++;
                            } else { }
                        } else {
                            newText += text[i];
                        }
                    }
                    text = newText;
                }
            }         
        }
    }

    Kirigami.Separator {
        QtLayouts.Layout.fillWidth: true
        QtLayouts.Layout.topMargin: Kirigami.Units.largeSpacing * 1
        QtLayouts.Layout.bottomMargin: Kirigami.Units.largeSpacing * 0.5
    }

    QC2.Label {
        QtLayouts.Layout.fillWidth: true
        QtLayouts.Layout.leftMargin: Kirigami.Units.largeSpacing * 2
        QtLayouts.Layout.rightMargin: Kirigami.Units.largeSpacing * 2
        text: i18n("When using custom indicator types, ensure your theme's font supports your desired character to prevent widget display issues.")
        font: Kirigami.Theme.smallFont
        wrapMode: Text.Wrap
    }
        
    Item {
        QtLayouts.Layout.fillHeight: true
    }

    Component.onCompleted: {
        if (Plasmoid.configuration.scrollWheelOn) {
            scrollWheelOn.checked = true;
        }
        if (!Plasmoid.configuration.desktopWrapOn) {
            desktopWrapOff.checked = true;
        }
        if (!Plasmoid.configuration.singleRow) {
            multiRow.checked = true;
        }
        if (Plasmoid.configuration.dotType == 0) {
            activeDot.text = "●"
            inactiveDot.text = "○"  
        }
    }
}
