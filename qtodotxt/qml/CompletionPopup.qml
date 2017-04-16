import QtQuick 2.5
import QtQuick.Controls 1.4


Rectangle {
    id: popup
    property Item textItem: TextArea {}
    property alias popupItem: popupItem

    height: popupItem.height
    width: popupItem.width

    state: "invisible"

    color: "white"
    border {
        color: "black"
        width: 1
    }
    //    opacity: 1

    function setPosition() {
        completionPrefixItem.text = completionModel.completionPrefix
        var _x = textItem.cursorRectangle.x
                + textItem.cursorRectangle.width - completionPrefixItem.contentWidth
        var _y = textItem.cursorRectangle.y
                + textItem.cursorRectangle.height + 5
        var globalCoords = textItem.mapToItem(splitView, _x, _y)
        x = globalCoords.x
        y = globalCoords.y
        //        console.log(x, y)
        //        x=0;y=0
    }

    function insertSelection(selectedText) {
        //        console.log(popup.textItem.cursorPosition, selectedText)
        popup.textItem.remove(popup.textItem.cursorPosition - completionModel.completionPrefix.length, popup.textItem.cursorPosition)
        popup.textItem.insert(popup.textItem.cursorPosition, selectedText)
        if (selectedText === "due:") {
            state = "calendar"
        }
        else  {
            popup.state = "invisible"
        }
    }

    Text {
        id: completionPrefixItem
        visible: false
        //text: completionModel.completionPrefix
        //        onTextChanged: console.log("txtlgth", contentWidth)
    }


    states: [
        State {
            name: "list"
            PropertyChanges {
                target: popup
                visible: true
            }
            PropertyChanges {
                target: popupItem
                sourceComponent: listComp
            }
            PropertyChanges {
                target: textItem
                Keys.forwardTo: [popupItem.item]
            }
        },
        State {
            name: "calendar"
            PropertyChanges {
                target: popup
                visible: true
            }
            PropertyChanges {
                target: popupItem
                sourceComponent: calendarComp
            }
            PropertyChanges {
                target: textItem
                Keys.forwardTo: [popupItem.item]
            }
        },
        State {
            name: "invisible"
            PropertyChanges {
                target: popup
                visible: false
                //                state: (completionModel.count > 0 ? "list": "invisible")
            }
        }

    ]

    ListModel {
        id: completionModel
        //property var sourceModel: ["(A)", "(B)", "(C)", "+project", "+projectasdasdsdasdasdasdasdasdasdasdasd", "@context"]
        property var sourceModel: mainController.completionStrings

        property string text: popup.textItem.text
        property int cursorPosition: popup.textItem.cursorPosition
        property string completionPrefix: ""//getCompletionPrefix(popup.textItem.text)

        onTextChanged: {
            completionPrefix = getCompletionPrefix(text)
            //            console.log(cursorPosition, completionPrefix)
        }

        function getCompletionPrefix(text) {
            var match = text.substring(0, cursorPosition).match(/(^.*\s|^)(\S+)$/)
            if (match) {
                return match[2]
            }
            return ""
        }


        onCompletionPrefixChanged: {
            //            console.log(completionPrefix)
            clear()
            if (completionPrefix.length > 0) {
                var filteredList = sourceModel.filter(function(completionItem) {
                    console.log("->", completionItem.substring(0, completionPrefix.length), completionPrefix)//typeof completionItem, typeof completionItem.toString())
                    //                    var ci = completionItem.toString()
                    return (completionItem.substring(0, completionPrefix.length) === completionPrefix)//completionItem.toString().startsWith(completionPrefix)
                })
                filteredList.forEach(function(i){
                    append({"text": i})
                })
                if (popup.state === "invisible") popup.setPosition()
                if (count > 0) popup.state = "list"
                else popup.state = "invisible"
            } else popup.state = "invisible"
        }
    }

    Loader {
        id: popupItem
    }

    Component {
        id: calendarComp
        Calendar {

        }
    }

    Component {
        id: listComp
        ListView {
            id: list
            //        anchors.fill:parent
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

            keyNavigationWraps: true

            Keys.enabled: popup.visible
            Keys.onEscapePressed: popup.state = "invisible"
            Keys.onReturnPressed: insertSelection(completionModel.get(currentIndex).text)

            //            Component.onCompleted: {console.log("huhu")}
        }
    }
}
