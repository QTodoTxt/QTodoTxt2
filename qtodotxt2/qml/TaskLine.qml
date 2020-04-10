import QtQuick 2.5
import QtQuick.Controls 1.4

import Theme 1.0


Loader {
    id: taskLine
    property var task
    property string text: ""
    property string html: ""
    property string priority: ""

    property bool current: false
    property bool hovered: false

    onCurrentChanged: {
        if (!current) state = "show"
    }
    signal inputAccepted(string newText)
    onInputAccepted: state = "show"

    state: "show"
    sourceComponent: labelComp

    Component {
        id: labelComp
        MouseArea {
            anchors.fill: parent
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
            property bool runQuitEdit: true
            property bool discard: false
            text: taskLine.text

            focus: true

            Keys.onReturnPressed: taskLine.inputAccepted(text)
            Keys.onEnterPressed: taskLine.inputAccepted(text)
            Keys.onEscapePressed: {
                discard = true
                taskLine.state = "show"
            }

            CompletionPopup { }
            Component.onCompleted: {
                forceActiveFocus() //helps, when searchbar is active
                cursorPosition = text.length
            }

            onActiveFocusChanged: {
                if (!activeFocus) {
                    console.log("lost focus")
                    taskLine.state = "show"
                }
            }
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
