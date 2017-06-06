import QtQuick 2.7
import QtQuick.Controls 1.4

TableView {
    id: listView
    property var taskList
    property alias currentIndex: listView.currentRow
    property int _lastIndex: 0

    function editCurrentTask() {
        if (currentItem !== null) {
            currentItem.state = "edit"
        }
    }

    headerVisible: false

    focus: true
    Keys.onReturnPressed: listView.currentItem.state = "edit"
    selectionMode: SelectionMode.MultiSelection

    model: taskList
    TableViewColumn {
        role: "html"
        delegate: TaskLine {
            width: listView.width

            text: taskList[model.index].text
            html: taskList[model.index].html
            priority: taskList[model.index].priorityHtml

            current: (currentIndex === styleData.row)

            onActivated: {
                console.log(listView.currentIndex, model.index)
                listView.activated(model.index)
//                listView.selection.select(model.index)
            }
            onShowContextMenu: contextMenu.popup()
    //        onStateChanged: if (state === "show") listView.focus = true
            onInputAccepted: {
                console.log("input acccepted text: ", newText)
                taskList[model.index].text = newText
            }
        }
    }

    onClicked: console.log(row)
}

