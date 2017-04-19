import QtQuick 2.5
import QtQuick.Controls 1.4


Loader {
    id: popup
    property Item textItem
//    property alias popupItem: item

    state: "unconnected"

    function setPosition() {
        prefixItem.text = completionModel.prefix
        var _x = textItem.cursorRectangle.x
                + textItem.cursorRectangle.width - prefixItem.contentWidth
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
        if (state === "list")
            popup.textItem.remove(popup.textItem.cursorPosition
                                  - completionModel.prefix.length,
                                  popup.textItem.cursorPosition)
        popup.textItem.insert(popup.textItem.cursorPosition, selectedText)
        completionModel.clear()
        if (selectedText === "due:") state = "calendar"
    }

    Keys.onEscapePressed: if (popup.state !== "invisible") popup.state = "invisible"

    Component {
        id: keyHandler
    Item {
//        focus: true
        Keys.onSpacePressed: {
            console.log("huhu")
            if (event.modifiers === Qt.ControlModifier) {
                completionModel.manualTrigger()
                event.accepted = true
            }
            else event.accepted = false
        }
    }
    }

    Text {
        id: prefixItem
        visible: false
    }

    onStateChanged: console.log("state: ", textItem, state)

    states: [
        State {
            name: "list"
            extend: "invisible"
            when: (textItem !== null && completionModel.count > 0)
            PropertyChanges {
                target: popup
//                visible: true
                sourceComponent: listComp
            }
            StateChangeScript {
                script: setPosition()
            }
        },
        State {
            name: "calendar"
            extend: "invisible"
            PropertyChanges {
                target: popup
//                visible: true
                sourceComponent: calendarComp
            }
            StateChangeScript {
                script: setPosition()
            }
        },
        State {
            name: "invisible"
            when: (textItem !== null && completionModel.count === 0)
            PropertyChanges {
                target: popup
                sourceComponent: keyHandler
                visible: true
            }
            PropertyChanges {
                target: completionModel
                text: textItem.text
                cursorPosition: textItem.cursorPosition
            }
            PropertyChanges {
                target: textItem
                Keys.forwardTo: [popup, popup.item]
            }
        },
        State {
            name: "unconnected"
            when: textItem === null
            PropertyChanges {
                target: popup
                visible: false
            }
        }
    ]

    ListModel {

        id: completionModel
        property var sourceModel: mainController.completionStrings

        property string text: ""
        property int cursorPosition: 0
        property string prefix: ""

        signal manualTrigger()

        function getPrefix() {
            var match = text.substring(0, cursorPosition).match(/(^.*\s|^)(\S+)$/)
            if (match) {
                prefix =  match[2]
            }
            else prefix = ""
        }

        function populateModel(){
            clear()
            if (popup.state === "unconnected") return;
            var filteredList = sourceModel.filter(function(completionItem) {
                return (completionItem.substring(0, prefix.length) === prefix)
            })
            filteredList.forEach(function(i){
                console.log(prefix, i)
                append({"text": i})
            })
        }

        onTextChanged: {
            getPrefix()
            if (prefix === "due:") popup.state = "calendar"
            if (prefix.length > 0) populateModel()
            else clear()
        }
        onManualTrigger: {
            getPrefix()
            if (prefix === "due:") popup.state = "calendar"
            populateModel()
        }
    }

    Component {
        id: calendarComp
        Calendar {
            signal selected()
            onSelected: {
                insertSelection(selectedDate.toLocaleString(Qt.locale("en_US"), 'yyyy-MM-dd'))
                popup.state = "invisible"
            }

            onClicked: selected()

//            focus: true
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

//            focus: true
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
                Keys.onLeftPressed: {
                    completionModel.clear()
                    event.accepted = false
                }
                Keys.onRightPressed:{
                    completionModel.clear()
                    event.accepted = false
                }
                Keys.onReturnPressed: selected()
                Keys.onEnterPressed: selected()
            }
        }
    }
}
