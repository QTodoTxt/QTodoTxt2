import QtQuick 2.7
import QtQuick.Controls 1.4

import Theme 1.0


Loader {
    id: taskLine
    property int index: 0
    property string text: ""
    property string html: ""
    property string priority: ""

    property bool current: false
//    onCurrentChanged: {
//        if (!current) state = "show"
//    }
    signal inputAccepted(int index, string newText)
//    onInputAccepted: state = "show"

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

//            text: taskLine.text

            focus: true

            Keys.onReturnPressed: taskLine.state = "show"
            Keys.onEnterPressed: taskLine.state = "show"
            Keys.onEscapePressed: {
//                discard = true
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

            Component.onDestruction: if (!discard) taskLine.inputAccepted(index, text)

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
