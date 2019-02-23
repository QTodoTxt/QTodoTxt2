import QtQuick 2.5
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
//    onStateChanged: console.log("taskline.state", state)
    sourceComponent: labelComp

    Component {
        id: labelComp
        MouseArea {
            anchors.fill: parent
//            width: taskLine.width
//            height: Math.max(label.height, 1) //Theme.minRowHeight)
            hoverEnabled: true
            propagateComposedEvents: true
            acceptedButtons: Qt.NoButton
            onEntered: taskLine.hovered = true
            onExited: taskLine.hovered = false
            property alias lblHeight: label.height
            Label {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                width: taskLine.width

                text: (task !== null ? task.html : "")
                textFormat: Qt.RichText
                wrapMode: Text.Wrap

                onLinkActivated:  Qt.openUrlExternally(link)
            }
        }
    }

    Component {
        id: editorComp
        TextArea {
            property bool runQuitEdit: true
            property bool discard: false

            focus: true

            height: Math.max(contentHeight, Theme.minRowHeight)

            Keys.onReturnPressed: taskLine.state = "show"
            Keys.onEnterPressed: taskLine.state = "show"
            Keys.onEscapePressed: {
                discard = true;
                taskLine.state = "show";
            }

            onActiveFocusChanged: {
//                console.log("activeFocusChanged", activeFocus, taskLine.state)
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
                height: Math.max(taskLine.item.lblHeight, Theme.minRowHeight)
            }
        },
        State {
            name: "edit"
            PropertyChanges {
                target: taskLine
                sourceComponent: editorComp
//                height: Math.max(taskLine.item.contentHeight, Theme.minRowHeight)
            }
        }
    ]
}
