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

//            Keys.onDownPressed: {
//                console.log("down")
//                if (completionRect.visible) completionList.focus = true
//            }

            Keys.forwardTo: [completionList]


            ListModel {
                id: completionModel
                property var sourceModel: ["(A)", "(B)", "(C)", "+project", "@context"]
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

            Rectangle {
                id: completionRect
                visible: completionModel.count > 0
                x: parent.cursorRectangle.x + parent.cursorRectangle.width
                y: parent.cursorRectangle.y + parent.cursorRectangle.height
                height: completionList.contentHeight
                width: completionList.contentWidth
                color: "white"
                border {
                    color: "black"
                    width: 2
                }

                ListView {
                    id: completionList
                    anchors.fill:parent

                    model: completionModel
                    delegate: Label { text: model.text }
                    highlight: Rectangle {
                        color: systemPalette.highlight
                        opacity: 0.5
                    }

                    keyNavigationWraps: true
                    Keys.onEscapePressed: completionRect.visible = false
                    Keys.onReturnPressed:
                        editor.insert(editor.cursorPosition, completionModel.get(currentIndex).text)
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
}
