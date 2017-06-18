import QtQuick 2.7
import QtQuick.Controls 1.4

import Theme 1.0


Loader {
    id: taskLine
    property var task
//    property string text: (task !== null ? task.text : "")
//    property string html: (task !== null ? task.html : "")

    property bool current: false
    property bool hovered: false

    state: "show"
    onStateChanged: console.log("taskline.state", state)
    sourceComponent: labelComp

    Component {
        id: labelComp
            Label {
                id: label
                anchors.verticalCenter: parent.verticalCenter
//                width: taskLine.width

                text: (task !== null ? task.html : "")
                textFormat: Qt.RichText
                wrapMode: Text.Wrap

                onLinkActivated:  Qt.openUrlExternally(link)
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    acceptedButtons: Qt.NoButton
                    onEntered: taskLine.hovered = true
                    onExited: taskLine.hovered = false
                }
            }
    }

    Component {
        id: editorComp
        TextArea {
            property bool runQuitEdit: true
            property bool discard: false

            focus: true

            Keys.onReturnPressed: taskLine.state = "show"
            Keys.onEnterPressed: taskLine.state = "show"
            Keys.onEscapePressed: {
                discard = true;
                taskLine.state = "show";
            }

            onActiveFocusChanged: {
                console.log("activeFocusChanged", activeFocus, taskLine.state)
                if (!activeFocus) {
                    console.log("lost focus")
                    taskLine.state = "show"
                }
            }

            Component.onCompleted: {
                forceActiveFocus() //helps, when searchbar is active
                text = task.text
                cursorPosition = text.length
            }

            Component.onDestruction: {
                if (!discard) task.text = text
                else if (task.text === "") task.text = ""
            }

            CompletionPopup { }
        }
    }


    states: [
        State {
            name: "show"
            PropertyChanges {
                target: taskLine
                sourceComponent: labelComp
                height: Math.max(taskLine.item.height, Theme.minRowHeight)
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
