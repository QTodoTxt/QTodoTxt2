import QtQuick 2.7
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

Dialog {
    id: window
    GroupBox {
        Column {
            spacing: 10
            CheckBox { text: qsTr("Autosave") }
            CheckBox { text: qsTr("AutoArchive") }
            CheckBox { text: qsTr("Add created date") }
            CheckBox { text: qsTr("Ask for confirmation before task completion") }
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
