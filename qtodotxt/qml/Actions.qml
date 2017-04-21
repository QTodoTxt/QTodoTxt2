import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.1

Item {
    property alias fileOpen: fileOpen
    property alias fileSaveAs: fileSaveAs

    Action {
        id: fileOpen
        iconName: "document-open"
        text: qsTr("Open")
        shortcut: StandardKey.Open
        onTriggered: {
            fileDialog.selectExisting = true
            fileDialog.open()
        }
    }

    Action {
        id: fileSaveAs
        iconName: "document-save-as"
        text: qsTr("Save As")
        shortcut: StandardKey.SaveAs
        onTriggered: {
            fileDialog.selectExisting = false
            fileDialog.open()
        }
    }


    FileDialog {
        //FIXME set default folder!
            id: fileDialog
            nameFilters: ["Text files (*.txt)"]
            onAccepted: {
                if (fileDialog.selectExisting) {
                    mainController.open(fileUrl)
                } else {
                    mainController.save(fileUrl)
                }
            }
    }

}

