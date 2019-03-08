import QtQuick 2.5
import QtQuick.Controls 1.4

import Theme 1.0


Loader {
    id: taskLine
    property string text: ""
    property string html: ""
    property string priority: ""

    property bool current: false
    onCurrentChanged: {
        if (!current) state = "show"
    }
    signal inputAccepted(string newText)
    onInputAccepted: state = "show"

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
            text: taskLine.text

            focus: true
            onEditingFinished: {
            }
            Keys.onReturnPressed: taskLine.inputAccepted(text)
            Keys.onEnterPressed: taskLine.inputAccepted(text)
            Keys.onEscapePressed: {
                //text = taskLine.text
                discard = true
                taskLine.state = "show"
            }

            CompletionPopup { }
            Component.onCompleted: {
                forceActiveFocus() //helps, when searchbar is active
                cursorPosition = text.length
            }

            onActiveFocusChanged: {
                if ( ! discard && ! activeFocus ) {
                    taskLine.inputAccepted(text)
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
