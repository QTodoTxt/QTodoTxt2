import QtQuick 2.5

Rectangle {
    id: completionRect
    property alias completionPrefix: completionModel.completionPrefix
    property alias cursorPosition: completionModel.cursorPosition
    property alias completionList: completionList


    x: parent.cursorRectangle.x + parent.cursorRectangle.width
    y: parent.cursorRectangle.y + parent.cursorRectangle.height
    height: completionList.contentHeight
    width: completionList.width

    state: "invisble"

    color: "white"
    border {
        color: "black"
        width: 2
    }
    opacity: 1

    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: completionRect
                visible: true
                parent: taskListView
            }
        },
        State {
            name: "invisible"
            PropertyChanges {
                target: completionRect
                visible: false
            }
        }

    ]

    ListModel {
        id: completionModel
        property var sourceModel: ["(A)", "(B)", "(C)", "+project", "+projectasdasdsdasdasdasdasdasdasdasdasd", "@context"]

        property var sourceModelTree: []
        property string completionPrefix: ""
        property int cursorPosition: 0

        onCompletionPrefixChanged: {
            clear()
            if (cursorPosition && completionPrefix) {
                var strToCursor = completionPrefix.substring(0,cursorPosition)
                var match = strToCursor.match(/(^.*\s|^)(\S+)$/)
                if (match) {
                    var curWord = match[2]
                    var filteredList = sourceModel.filter(function(completionItem) {
                        console.log(typeof completionItem)
                        completionItem.toString()
                        return completionItem.startsWith(curWord)
                    })
                    console.log(curWord, filteredList)
                    if (filteredList.length > 0) populateModel(filteredList)
                }
            }
        }

        function populateModel(filteredList) {
            filteredList.forEach(function(i){
                append({"text": i})
            })
            if (count > 0) completionRect.state = visible
        }
    }

    ListView {
        id: completionList
        anchors.fill:parent

        model: completionModel
        delegate:
            Text {
            id: complItemTxt
            text: model.text
            width: Math.max(contentWidth, 50)
        }
        highlight: Rectangle {
            color: systemPalette.highlight
            opacity: 0.5
        }

        keyNavigationWraps: true

        Keys.enabled: completionModel.count > 0
        Keys.onEscapePressed: completionRect.state = "invisible"
        Keys.onReturnPressed:
            editor.insert(editor.cursorPosition, completionModel.get(currentIndex).text)
    }
}
