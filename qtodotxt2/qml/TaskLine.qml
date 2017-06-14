import QtQuick 2.7
import QtQuick.Controls 1.4

import Theme 1.0


Loader {
    id: taskLine
    property var task
    property string text: task.text
    property string html: task.html

    property bool current: false

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
            property bool discard: false
            property bool accepted: false

            focus: true

            Keys.onReturnPressed: taskLine.state = "show"
            Keys.onEnterPressed: taskLine.state = "show"
            Keys.onEscapePressed: {
                if (taskLine.text === "") text = ""
                else discard = true
                taskLine.state = "show"
            }

            onActiveFocusChanged: if (!activeFocus) taskLine.state = "show"

            Component.onCompleted: {
                forceActiveFocus() //helps, when searchbar is active
                text = taskLine.text
                cursorPosition = text.length
            }

            Component.onDestruction: if (!discard) task.text = text

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
