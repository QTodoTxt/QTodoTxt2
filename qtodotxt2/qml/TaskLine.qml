import QtQuick 2.7
import QtQuick.Controls 1.4


Loader {
    id: taskLine
    property string text: ""
    property string html: ""
    property string priority: ""

    property bool current: false
    onCurrentChanged: {
//        console.log("currentCh")
        if (!current) state = "show"
    }
    signal activated()
    signal showContextMenu()
    signal inputAccepted(string newText)
    onInputAccepted: state = "show"

    state: "show"
    sourceComponent: labelComp

    Component {
        id: labelComp
        Item {
            anchors.fill: parent
            property alias lblHeight: label.height

//            propagateComposedEvents: true
//            acceptedButtons: Qt.LeftButton | Qt.RightButton
//            onClicked: {
//                taskLine.activated()
//                if (mouse.button === Qt.RightButton) taskLine.showContextMenu()
//                mouse.accepted = false
//            }
//            onDoubleClicked: {
//                taskLine.activated()
//                taskLine.state = "edit"
//                mouse.accepted = false
//            }
            Label {
                id: label
                anchors.verticalCenter: parent.verticalCenter

                text: taskLine.html
                textFormat: Qt.RichText
                wrapMode: Text.Wrap
                width: taskLine.width

                onLinkActivated:  Qt.openUrlExternally(link)
            }
        }
    }

    Component {
        id: editorComp
        TextArea {
//            id: editor
            property bool discard: false
            text: taskLine.text

            focus: true
            onEditingFinished: {
//                taskLine.state = "show"
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
                height: taskLine.item.lblHeight + 10
            }
        },
        State {
            name: "edit"
            PropertyChanges {
                target: taskLine
                sourceComponent: editorComp
                height: taskLine.item.contentHeight + 10
            }
        }
    ]
//    Component.onCompleted: console.log(text.substring(0,10))
}
