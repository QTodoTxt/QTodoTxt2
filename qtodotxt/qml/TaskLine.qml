import QtQuick 2.2
import QtQuick.Controls 1.4


Loader {
    id: taskLine
    property string text: ""
    property string html: ""

    property bool current: false
    onCurrentChanged: if (!current) state = "show"
    signal activated()
    signal showContextMenu()

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
                id: label
                anchors.verticalCenter: parent.verticalCenter
                text: taskLine.html
                width: taskLine.width
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
            //            onActiveFocusChanged: if (!activeFocus) taskLine.state = "show"

            onTextChanged: {
                completionModel.completionPrefix = text
                completionList.visible = true
//                completionList.focus = true
            }

            onCursorPositionChanged: {
                completionModel.cursorPosition = cursorPosition
            }

            ListModel {
                id: completionModel
                property var sourceModel: ["(A)", "(B)", "(C)"]
                property string completionPrefix: parent.text
                property int cursorPosition: parent.cursorPosition

                onCompletionPrefixChanged: {
                    clear()
                    if (cursorPosition && completionPrefix) {
                    var strToCursor = completionPrefix.substring(0,cursorPosition)
                    var curWord = strToCursor.match(/.*\s(.+)/)[1]
                    if (curWord === "(") populateModel()
                }
                }

                function populateModel() {
                    sourceModel.forEach(function(i){
                    append({"text": i})
                    })
                }

            }

            ListView {
                id: completionList
                x: parent.cursorRectangle.x + parent.cursorRectangle.width
                y: parent.cursorRectangle.y + parent.cursorRectangle.height
                visible: completionModel.count > 0
                model: completionModel
                delegate: Label { text: modelData }
                height: contentHeight
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
