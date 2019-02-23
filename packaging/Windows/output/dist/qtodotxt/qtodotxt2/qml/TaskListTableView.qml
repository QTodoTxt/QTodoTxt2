import QtQuick 2.5
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.4

import Theme 1.0


TableView {
    //TODO select after start and new filter

    id: listView
    property var taskList: []
    onTaskListChanged: {
//        console.log("taskListChanged", currentRow)
//        restoreSelection()
    }
    property alias currentIndex: listView.currentRow
    property Item currentItem
//    onCurrentItemChanged: console.log("currentItem", currentRow, currentItem, typeof currentItem)
    onCurrentRowChanged: {
//        console.log("currentRow", currentRow)
//        selection.select(currentRow, currentRow)
    }
    property int lastIndex: 0
    property bool editing: (currentItem !== null ? currentItem.state === "edit" : false)
    onEditingChanged: console.log("editing", editing)

    selection.onSelectionChanged: {
//        console.log("selection.count", selection.count, currentRow)
        if (selection.count === 0) {
            if (currentRow > -1) {
                selection.select(currentRow)
            } else {
                currentItem = null
            }
        }
    }


    signal rowHeightChanged(int row, real rowHeight)
    signal rowHoveredChanged(int row, bool rowHovered)

    function newTask(template) {
        quitEditing()
//        console.log("creating new task")
        var idx = mainController.newTask(template, taskListView.currentIndex)
//        console.log("selecting new task")
        currentRow = idx
        selection.select(idx)
//        console.log("editing new task")
        editCurrentTask()
    }

    function newFromTask() {
        if ( taskListView.currentItem !== null ) {
            var text = taskListView.currentItem.task.text
            newTask(text)
        }
    }

    function editCurrentTask() {
        if (currentItem !== null) {
            currentItem.state = "edit"
        }
    }

    function deleteSelectedTasks() {
        if (selection.count > 0) deleteDialog.open()
    }

    MessageDialog {
        id: deleteDialog
        title: "QTodotTxt Delete Tasks"
        text: "Do you really want to delete " + (selection.count === 1 ? "1 task?" : "%1 tasks?".arg(selection.count))
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            taskListView.storeSelection()
            console.log("deleting tasks %1".arg(getSelectedIndexes()))
            mainController.deleteTasks(getSelectedIndexes())
            taskListView.restoreSelection()
        }
    }

    function quitEditing() {
        if (editing) currentItem.state = "show"
    }

    function storeSelection() {
//        console.log("storing selection")
        lastIndex = currentRow
    }

    function restoreSelection() {
//        console.log("restoring selection", lastIndex)
        currentRow = Math.min(lastIndex, taskListView.rowCount - 1)
        selection.clear()
        selection.select(currentRow)
    }


    function getSelectedIndexes() {
        var indexes = []
        selection.forEach(function(rowIndex) {
            indexes.push(rowIndex);
        })
        return indexes;
    }

    //selection.onSelectionChanged: console.log("sc", getSelectedIndexes());

    focus: true
    Keys.onReturnPressed: editCurrentTask()
    selectionMode: SelectionMode.ExtendedSelection

    headerVisible: false
    model: taskList

    rowDelegate: Rectangle {
        id: rect
        height: Theme.minRowHeight
        property bool hovered: false
        color: {
            var baseColor = styleData.alternate ? Theme.activePalette.alternateBase : Theme.activePalette.base
            var hoverBaseColor = rect.hovered ? Theme.inactivePalette.highlight : baseColor
            var highlightColor = listView.activeFocus ? Theme.activePalette.highlight : Theme.inactivePalette.highlight
            var hoverHighlightColor = rect.hovered ? Qt.lighter(highlightColor, 1.2) : highlightColor
            return styleData.selected ? hoverHighlightColor : hoverBaseColor
        }
        opacity: hovered && !styleData.selected ? 0.5 : 1
//        onColorChanged: console.log(color)

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            acceptedButtons: Qt.RightButton
            hoverEnabled: true
            onClicked: contextMenu.popup()
            onEntered: rect.hovered = true
            onExited: {
                rect.hovered = false
//                console.log("exited")
            }
        }
        Connections {
            target: listView
            onRowHeightChanged: {
//                console.log("rhc", row, rowHeight)
                if (styleData.row === row) rect.height = rowHeight
            }
        }
        Connections {
            target: listView
            onRowHoveredChanged: {
                if (styleData.row === row) rect.hovered = rowHovered
            }
        }
     }

    TableViewColumn {
        role: "html"
        delegate: TaskLine {

            current: (styleData.selected && listView.currentRow === styleData.row)
            onCurrentChanged: {
                if (current) listView.currentItem = this
            }
            onHeightChanged: {
                listView.rowHeightChanged(styleData.row, height)
            }
            onHoveredChanged: {
                listView.rowHoveredChanged(styleData.row, hovered)
            }
            Component.onCompleted: task = taskList[styleData.row]
        }
    }

    onDoubleClicked: editCurrentTask()//console.log("tv dc", row)

    Menu {
        id: contextMenu
        MenuItem { action: actions.newTask }
        MenuItem { action: actions.editTask }
    }
}

