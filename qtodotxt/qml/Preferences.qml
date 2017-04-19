import QtQuick 2.7
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import Qt.labs.settings 1.0

Dialog {
    id: window
    Settings {
        category: "Preferences"
        property alias auto_save: autoSaveCB.checked
        //property alias window_height: window.height
        //property alias filters_tree_width: filtersTree.width
    }
    GroupBox {
        Column {
            spacing: 10
            CheckBox { 
                id: autoSaveCB
                text: qsTr("Autosave") 
                checked: true
            }
            CheckBox { text: qsTr("AutoArchive") }
            CheckBox { text: qsTr("Add created date") }
            CheckBox { text: qsTr("Show Delete action") }
            Row { Label {text: "Lowest task priority:"}
                TextField { text: "D"; inputMask: "A" }
            }
            CheckBox { text: qsTr("Enable System Tray") }
        }
    }
    standardButtons:StandardButton.Ok
    onVisibleChanged: if (visible === false) destroy()
    Component.onDestruction: console.log("Tschüüüs.")
}
