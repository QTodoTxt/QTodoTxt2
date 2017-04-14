import QtQuick 2.2
import QtQuick.Controls 1.4


Loader {
    id: taskLine
    property string text: ""
    property string html: ""
    property string priority: ""

    property bool current: false
    onCurrentChanged: if (!current) state = "show"
    signal activated()
    signal showContextMenu()
    signal inputAccepted(string newText)
    onInputAccepted: state = "show"

    state: "show"
    sourceComponent: labelComp

    Component {
        id: labelComp
        MouseArea {
            anchors.fill: parent
            property alias lblHeight: label.height
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                taskLine.activated()
                if (mouse.button === Qt.RightButton) taskLine.showContextMenu()
            }
            onDoubleClicked: {
                taskLine.activated()
                taskLine.state = "edit"
            }
            Label {
                id: prioLbl
                anchors.verticalCenter: parent.verticalCenter
                width: 20

                text: taskLine.priority
                textFormat: Qt.RichText
            }
            Label {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.left: prioLbl.right

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
            id: editor
            //            width: taskLine.width
            //            anchors.verticalCenter: parent.verticalCenter

            text: taskLine.text
            focus: true
            onEditingFinished: {
                taskLine.state = "show"
            }
            Keys.onReturnPressed: taskLine.inputAccepted(editor.text)
            Keys.onEnterPressed: taskLine.inputAccepted(editor.text)
            Keys.onEscapePressed: taskLine.state = "show"

            //            onActiveFocusChanged: if (!activeFocus) taskLine.state = "show"

//            onTextChanged: {
//                completionPopup.completionPrefix = text
//                //completionList.visible = true
//                //                completionList.focus = true
//            }

//            onCursorPositionChanged: {
//                completionPopup.cursorPosition = cursorPosition
//            }

            //            Keys.onDownPressed: {
            //                console.log("down")
            //                if (completionRect.visible) completionList.focus = true
            //            }

            Keys.forwardTo: [completionPopup.completionList]

            CompletionPopup {
                id: completionPopup
                textItem: parent
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
}
