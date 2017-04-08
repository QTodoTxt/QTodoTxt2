import QtQuick 2.7
import QtQuick.Window 2.1
import QtQuick.Controls 2.1

Window {
    id: window
    Column {
        CheckBox { text: qsTr("Autosave") }
        CheckBox { text: qsTr("AutoArchive") }
        CheckBox { text: qsTr("Add created date") }
        CheckBox { text: qsTr("Ask for confirmation before task completion") }
        Button {
            text: qsTr("Ok")
            onClicked: window.close()
        }
    }
}
