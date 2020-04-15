import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import Qt.labs.settings 1.0

Dialog {
    id: prefWindow
    width: 270
    height: 350
    title: "Preferences"
    Settings {
        category: "Preferences"
        property alias auto_save: autoSaveCB.checked
        property alias auto_reload: autoReloadCB.checked
        property alias singleton: singletonCB.checked
        property alias lowest_priority: lowestPriorityField.text
        property alias add_creation_date: creationDateCB.checked
    }
    GroupBox {
        anchors.bottomMargin: 230
        anchors.rightMargin: 365
        anchors.fill: parent

        Column {
            x: 1
            y: 2
            width: 250
            height: 330
            spacing: 10

            CheckBox {
                id: singletonCB
                text: qsTr("Single instance") 
                checked: false
            }
            CheckBox { 
                id: autoSaveCB
                text: qsTr("Autosave") 
                checked: true
            }
            CheckBox {
                id: autoReloadCB
                text: qsTr("Auto-reload")
                checked: false
            }
            CheckBox {
                id:creationDateCB
                text: qsTr("Add creation date")
                checked: false
            }
            Row { 
                Label {text: "Lowest task priority:"}
                TextField { 
                    id: lowestPriorityField;
                    text: "G"
                    inputMask: "A"
                }
            }
        }

        Button {
            id: button
            x: 38
            y: 219
            width: 175
            height: 30
            text: qsTr("Change Font Here")
            anchors.horizontalCenter: parent
            onClicked: {
                fontDialogId.open()
            }
        }

            FontDialog {
            id: fontDialogId
            title: "Choose a font"
            font: Qt.font({family: "Arial", pointSize: 12, weight: Font.Normal})

            onAccepted: {
                console.log("You chose : "+font)
                textId.font = fontDialogId.font
            }

            onRejected: {
                console.log("Dialog rejected")
            }
        }
    }

    standardButtons:StandardButton.Ok
    onVisibleChanged: if (visible === false) destroy()
}

