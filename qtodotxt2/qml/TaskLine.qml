import QtQuick 2.7
import QtQuick.Controls 1.4

import Theme 1.0


Loader {
    id: taskLine
    property var task
    property string text: (task !== null ? task.text : "")
    property string html: (task !== null ? task.html : "")

    property bool current: false

    property bool runQuitEdit: true
    function quitEdit(acceptInput, newText) {
        if (runQuitEdit) {
            runQuitEdit = false
            console.log("setting new text")
            task.text = newText
            taskLine.state = "show"
        }
    }

    state: "show"
    sourceComponent: labelComp

    Component {
        id: labelComp
        Item {
            anchors.fill: parent
            property alias lblHeight: label.height

            Label {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                width: taskLine.width

                text: taskLine.html
                textFormat: Qt.RichText
                wrapMode: Text.Wrap

                onLinkActivated:  Qt.openUrlExternally(link)
            }
        }
    }

    Component {
        id: editorComp
        TextArea {
//            property bool discard: false

            focus: true

            Keys.onReturnPressed: quitEdit(true, text) //taskLine.state = "show"
            Keys.onEnterPressed: quitEdit(true, text) //taskLine.state = "show"
            Keys.onEscapePressed: {
                if (taskLine.text === "") quitEdit(true, "")
                else quitEdit(false, "")
            }

            onActiveFocusChanged: {
                console.log("activeFocusChanged", activeFocus, taskLine.state)
                if (!activeFocus) {
                    console.log("lost focus")
                    quitEdit(true, text)
                }
            }

            Component.onCompleted: {
                forceActiveFocus() //helps, when searchbar is active
                text = taskLine.text
                cursorPosition = text.length
            }

//            Component.onDestruction: if (!discard) task.text = text

            CompletionPopup { }
        }
    }


    states: [
        State {
            name: "show"
            PropertyChanges {
                target: taskLine
                sourceComponent: labelComp
                height: Math.max(taskLine.item.lblHeight, Theme.minRowHeight)
            }
        },
        State {
            name: "edit"
            PropertyChanges {
                target: taskLine
                sourceComponent: editorComp
                height: Math.max(taskLine.item.contentHeight, Theme.minRowHeight)
            }
        }
    ]
}
