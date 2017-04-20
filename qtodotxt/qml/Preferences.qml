import QtQuick 2.7
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import Qt.labs.settings 1.0

Dialog {
    id: window
    Settings {
        category: "Preferences"
        property alias auto_save: autoSaveCB.checked
        property alias lowest_priority: lowestPriorityField.text
        property alias add_creation_date: creationDateCB.checked
    }
    GroupBox {
        Column {
            spacing: 10
            CheckBox { 
                id: autoSaveCB
                text: qsTr("Autosave") 
                checked: true
            }
            //CheckBox { text: qsTr("AutoArchive") }
            CheckBox {
                id:creationDateCB
                text: qsTr("Add creation date")
                checked: false
            }
            Row { 
                Label {text: "Lowest task priority:"}
                TextField { 
                    id: lowestPriorityField; 
                    text: "D"; 
                    inputMask: "A" 
                }
            }
            //CheckBox { text: qsTr("Enable System Tray") }
        }
    }
    standardButtons:StandardButton.Ok
    onVisibleChanged: if (visible === false) destroy()
    Component.onDestruction: console.log("Tschüüüs.")
}
