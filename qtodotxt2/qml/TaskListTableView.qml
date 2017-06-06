import QtQuick 2.7
import QtQuick.Controls 1.4

TableView {
    id: listView
    property var taskList
    property alias currentIndex: listView.currentRow
    property Item currentItem
    property int _lastIndex: 0

    function editCurrentTask() {
        if (currentItem !== null) {
            currentItem.state = "edit"
        }
    }

    headerVisible: false

    focus: true
    Keys.onReturnPressed: editCurrentTask()
    selectionMode: SelectionMode.ExtendedSelection

    model: taskList
    TableViewColumn {
        role: "html"
        delegate: TaskLine {
            width: listView.width

            text: taskList[model.index].text
            html: taskList[model.index].html
            priority: taskList[model.index].priorityHtml

            current: (listView.currentRow === styleData.row)
            onCurrentChanged: {
                console.log("current", current, styleData.row)
                if (current) listView.currentItem = this
            }

            onShowContextMenu: contextMenu.popup()
            onInputAccepted: {
                console.log("input acccepted text: ", newText)
                taskList[model.index].text = newText
            }
        }
    }

    onClicked: console.log("tv cl", row)
    onDoubleClicked: editCurrentTask()//console.log("tv dc", row)
}

