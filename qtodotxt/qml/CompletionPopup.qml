import QtQuick 2.5
import QtQuick.Controls 1.4


Loader {
    id: popup
    property Item textItem
//    property alias popupItem: item

    state: "unconnected"

    function setPosition() {
        completionPrefixItem.text = completionModel.completionPrefix
        var _x = textItem.cursorRectangle.x
                + textItem.cursorRectangle.width - completionPrefixItem.contentWidth
        var _y = textItem.cursorRectangle.y
                + textItem.cursorRectangle.height + 5
        var globalCoords = textItem.mapToItem(splitView, _x, _y)
        var xMax = splitView.width - popup.width
        var yMax = splitView.height - popup.height
        x = Math.min(globalCoords.x, xMax)
        y = Math.min(globalCoords.y, yMax)
        //        console.log(x, y)
        //        x=0;y=0
    }

    function insertSelection(selectedText) {
        console.log(popup.textItem.cursorPosition, selectedText)
        popup.textItem.remove(popup.textItem.cursorPosition - completionModel.completionPrefix.length, popup.textItem.cursorPosition)
        popup.textItem.insert(popup.textItem.cursorPosition, selectedText)
        if (selectedText === "due:") {
            completionModel.completionPrefix = ""
            state = "calendar"
            setPosition()
        }
        else  {
            popup.state = "invisible"
        }
    }

    Text {
        id: completionPrefixItem
        visible: false
    }


    focus: true
    Keys.onEscapePressed: popup.state = "invisible"

    onTextItemChanged: if (textItem) state = "invisible"

    onStateChanged: console.log("state: ", textItem, state)

    states: [
        State {
            name: "list"
            PropertyChanges {
                target: popup
                visible: true
                sourceComponent: listComp
            }
            PropertyChanges {
                target: textItem
                Keys.forwardTo: [popup, popup.item]
            }
            PropertyChanges {
                target: completionModel
                text: textItem.text
                cursorPosition: textItem.cursorPosition
            }
            StateChangeScript {
                script: setPosition()
            }
        },
        State {
            name: "calendar"
            PropertyChanges {
                target: popup
                visible: true
                sourceComponent: calendarComp
            }
            PropertyChanges {
                target: textItem
                Keys.forwardTo: [popup, popup.item]
            }
            StateChangeScript {
                script: setPosition()
            }
        },
        State {
            name: "invisible"
            PropertyChanges {
                target: popup
                visible: false
            }
            PropertyChanges {
                target: completionModel
                text: textItem.text
                cursorPosition: textItem.cursorPosition
            }
        },
        State {
            name: "unconnected"
            when: textItem === null
            PropertyChanges {
                target: popup
                visible: false
            }
            PropertyChanges {
                target: completionModel
                text: ""
                cursorPosition: 0
            }
        }

    ]

    ListModel {

        id: completionModel
        property var sourceModel: mainController.completionStrings

        property string text: ""
        property int cursorPosition: 0
        property string completionPrefix: ""


        function getCompletionPrefix() {
            var match = text.substring(0, cursorPosition).match(/(^.*\s|^)(\S+)$/)
            if (match) {
                return match[2]
            }
            return ""
        }

        function populateModel(){
            clear()
            if (popup.state === "unconnected") return;
            var filteredList = sourceModel.filter(function(completionItem) {
                return (completionItem.substring(0, completionPrefix.length) === completionPrefix)
            })
            filteredList.forEach(function(i){
                console.log(completionPrefix, i)
                append({"text": i})
            })
        }
        signal manualTrigger()

        onTextChanged: completionPrefix = getCompletionPrefix()
        onManualTrigger: completionPrefix = getCompletionPrefix()
        onCompletionPrefixChanged: populateModel()
        onCountChanged: if (count > 0) popup.state = "list"
    }

    Component {
        id: calendarComp
        Calendar {
            signal selected()
            onSelected: insertSelection(selectedDate.toLocaleString(Qt.locale("en_US"), 'yyyy-MM-dd'))
            onClicked: selected()

            focus: true
            Keys.onRightPressed: {
                if (event.modifiers === Qt.ControlModifier) {
                    var d = new Date(selectedDate)
                    d.setDate(d.getDate() - 1)
                    selectedDate = new Date(d.setMonth(d.getMonth() + 1))
                    event.accepted
                }
            }
            Keys.onLeftPressed: {
                if (event.modifiers === Qt.ControlModifier) {
                    var d = new Date(selectedDate)
                    d.setDate(d.getDate() + 1)
                    selectedDate = new Date(d.setMonth(d.getMonth() - 1))
                    event.accepted
                }
            }
            Keys.onDownPressed: {
                if (event.modifiers === Qt.ControlModifier) {
                    var d = new Date(selectedDate)
                    d.setDate(d.getDate() - 7)
                    selectedDate = new Date(d.setFullYear(d.getFullYear() + 1))
                    event.accepted
                }
            }
            Keys.onUpPressed: {
                if (event.modifiers === Qt.ControlModifier) {
                    var d = new Date(selectedDate)
                    d.setDate(d.getDate() + 7)
                    selectedDate = new Date(d.setFullYear(d.getFullYear() - 1))
                    event.accepted
                }
            }
            Keys.onReturnPressed: selected()
            Keys.onEnterPressed: selected()
//            Keys.onEscapePressed: popup.state = "invisible"
        }
    }

    Component {
        id: listComp
        Rectangle {
            height: list.height
            width: list.width

            color: "white"
            border {
                color: "black"
                width: 1
            }

            focus: true
            Keys.forwardTo: list

            ListView {
                id: list

                signal selected()
                onSelected: insertSelection(completionModel.get(currentIndex).text)

                height: contentHeight
                width: 200

                model: completionModel
                delegate:
                    Text {
                    id: complItemTxt
                    text: model.text
                    width: list.width
                }
                highlight: Rectangle {
                    color: systemPalette.highlight
                    opacity: 0.5
                }

                focus: true
                keyNavigationWraps: true
                //Keys.enabled: popup.visible
//                Keys.onEscapePressed: popup.state = "invisible"
                Keys.onReturnPressed: selected()
                Keys.onEnterPressed: selected()
            }
        }
    }
}
