import QtQuick 2.5
import QtQuick.Controls 1.4

Rectangle {
    id: popup
    //property alias textItem: completionModel.textItem
    property TextArea textItem: TextArea {}
    //    property alias completionPrefix: completionModel.completionPrefix
    //    property alias cursorPosition: completionModel.cursorPosition
    property alias completionList: completionList

    //    x: parent.cursorRectangle.x + parent.cursorRectangle.width
    //    y: parent.cursorRectangle.y + parent.cursorRectangle.height
    height: completionList.height
    width: completionList.width

    state: "invisible"

    color: "white"
    border {
        color: "black"
        width: 1
    }
    //    opacity: 1

    function setPosition() {
        completionPrefixItem.text = completionModel.completionPrefix
        x = textItem.x + textItem.cursorRectangle.x
                + textItem.cursorRectangle.width - completionPrefixItem.contentWidth
        y = textItem.y + textItem.cursorRectangle.y
                + textItem.cursorRectangle.height
    }

    function insertSelection(selectedText) {
        console.log(popup.textItem.cursorPosition, selectedText)
        popup.textItem.remove(popup.textItem.cursorPosition - completionModel.completionPrefix.length, popup.textItem.cursorPosition)
        popup.textItem.insert(popup.textItem.cursorPosition, selectedText)
        popup.state = "invisible"
    }

    Text {
        id: completionPrefixItem
        visible: false
        //text: completionModel.completionPrefix
        onTextChanged: console.log("txtlgth", contentWidth)
    }

    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: popup
                visible: true
            }
        },
        State {
            name: "invisible"
            PropertyChanges {
                target: popup
                visible: false
                //                state: (completionModel.count > 0 ? "visible": "invisible")
            }
        }

    ]

    ListModel {
        id: completionModel
        property var sourceModel: ["(A)", "(B)", "(C)", "+project", "+projectasdasdsdasdasdasdasdasdasdasdasd", "@context"]

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
            console.log(completionPrefix)
            clear()
            if (completionPrefix.length > 0) {
                var filteredList = sourceModel.filter(function(completionItem) {
                    //                console.log(typeof completionItem)
                    completionItem.toString()
                    return completionItem.startsWith(completionPrefix)
                })
                filteredList.forEach(function(i){
                    append({"text": i})
                })
                if (popup.state === "invisible") popup.setPosition()
                if (count > 0 && !popup.visible) popup.state = "visible"
            }
        }
    }

    ListView {
        id: completionList
        //        anchors.fill:parent
        height: contentHeight
        width: 200

        model: completionModel
        delegate:
            Text {
            id: complItemTxt
            text: model.text
            width: completionList.width
        }
        highlight: Rectangle {
            color: systemPalette.highlight
            opacity: 0.5
        }

        keyNavigationWraps: true

        Keys.enabled: popup.visible
        Keys.onEscapePressed: popup.state = "invisible"
        Keys.onReturnPressed: insertSelection(completionModel.get(currentIndex).text)
    }
}
