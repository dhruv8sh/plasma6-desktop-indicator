import QtQuick
import QtQuick.Controls as QC2
import QtQuick.Layouts as QtLayouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

QtLayouts.ColumnLayout {
    id: generalPage

    signal configurationChanged

    property alias cfg_middleButtonCommand: middleButtonCommand.text
    property alias cfg_desktopWrapOn      : desktopWrapOn.checked
    property alias cfg_singleRow          : singleRow.checked
    property alias cfg_activeText         : activeDot.text
    property alias cfg_inactiveText       : inactiveDot.text
    property alias cfg_spacingHorizontal  : spacingHorizontal.value
    property alias cfg_spacingVertical    : spacingVertical.value
    property alias cfg_dotSizeCustom      : dotSizeCustom.value
    property alias cfg_boldOnActive       : boldOnActive.checked
    property alias cfg_italicOnActive     : italicOnActive.checked
    property alias cfg_highlightOnActive  : highlightOnActive.checked
    property alias cfg_indicatorType      : indicatorType.currentIndex
    property alias cfg_showAddDesktop     : showAddDesktop.checked
    property alias cfg_radiusFactor      : radiusSlider.value

    Kirigami.FormLayout {

        QtLayouts.RowLayout {
            Kirigami.FormData.label: i18n("Middle click command:")
            QC2.TextField {
                id: middleButtonCommand
            }
        }
    
        Item {
            Kirigami.FormData.isSection: true
        }
        QtLayouts.ColumnLayout {
            Kirigami.FormData.label: i18n("Navigation behaviour:")
            Kirigami.FormData.buddyFor: desktopWrapOn
            QC2.CheckBox {
                id: desktopWrapOn
                text: i18n("Wraparound")
            }
            QC2.CheckBox {
                id: showAddDesktop
                text: i18n("Show Add Desktop Button")
                enabled: singleRow.checked
            }
        }
        QtLayouts.ColumnLayout {
            Kirigami.FormData.label: i18n("On Active:")
            Kirigami.FormData.buddyFor: boldOnActive
            QC2.CheckBox {
                id: boldOnActive
                text: i18n("Bold")
            }
            QC2.CheckBox {
                id: italicOnActive
                text: i18n("Italic")
            }
            QC2.CheckBox {
                id: highlightOnActive
                text: i18n("Highlight")
            }
        }
        QtLayouts.ColumnLayout{
            Kirigami.FormData.label: i18n("Highlight radius:")
            Kirigami.FormData.buddyFor: radiusSlider
            QC2.Slider {
                id: radiusSlider
                enabled: highlightOnActive.checked
                height: 30
                from: 0
                to: 1
                stepSize: 0.1
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
                checked: plasmoid.configuration.singleRow
            }

            QC2.RadioButton {
                id: multiRow
                text: i18n("Follow Plasma setting")
                checked: !plasmoid.configuration.singleRow
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QtLayouts.RowLayout {
            Kirigami.FormData.label: i18n("Indicator Dot Size:")

            QC2.SpinBox {
                id: dotSizeCustom
                textFromValue: function(value) {
                    return i18n("%1 px", value)
                }
                valueFromText: function(text) {
                    return parseInt(text)
                }
                from: 6
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
                to: 30
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
            Kirigami.FormData.label: i18n("Indicator style:")
            Kirigami.FormData.buddyFor: indicatorType
            QtLayouts.Layout.fillWidth: true
            QC2.ComboBox {
                id: indicatorType
                model: [
                    i18n("Custom"),
                    i18n("Workspace Numbers")
                ]
            }

            QC2.Label {
                text: i18n("Active Dot:")
                QtLayouts.Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                visible: indicatorType.currentIndex == 0
            }
            QC2.TextField {
                id: activeDot
                QtLayouts.Layout.maximumWidth: 35
                maximumLength: 1
                text: Plasmoid.configuration.activeDot
                horizontalAlignment: TextInput.AlignHCenter
                visible: indicatorType.currentIndex == 0
            }        
            Item {
                width: 5
            }
        
            QC2.Label {
                text: i18n("Inactive Dot:")
                QtLayouts.Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                visible: indicatorType.currentIndex == 0
            }

            QC2.TextField {
                id: inactiveDot
                QtLayouts.Layout.maximumWidth: 35
                maximumLength: 1
                text: Plasmoid.configuration.inactiveDot
                horizontalAlignment: TextInput.AlignHCenter
                visible: indicatorType.currentIndex == 0
            }         
        }
    }

    Kirigami.Separator {
        QtLayouts.Layout.fillWidth: true
        QtLayouts.Layout.topMargin: Kirigami.Units.largeSpacing * 1
        QtLayouts.Layout.bottomMargin: Kirigami.Units.largeSpacing * 0.5
        visible: indicatorType.currentIndex == 0
    }

    QC2.Label {
        QtLayouts.Layout.fillWidth: true
        QtLayouts.Layout.leftMargin: Kirigami.Units.largeSpacing * 2
        QtLayouts.Layout.rightMargin: Kirigami.Units.largeSpacing * 2
        text: i18n("When using custom indicator types, ensure your theme's font supports your desired character to prevent widget display issues.")
        font: Kirigami.Theme.smallFont
        wrapMode: Text.Wrap
        visible: indicatorType.currentIndex == 0
    }
        
    Item {
        QtLayouts.Layout.fillHeight: true
    }
}
