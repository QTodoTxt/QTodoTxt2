import QtQuick 2.7
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.4

import Theme 1.0

TableView {

    //TODO delete (all selected)

    id: listView
    property var taskList
    property alias currentIndex: listView.currentRow
    property Item currentItem
    property int _lastIndex: 0
//    property bool editing: currentItem.state === "edit"
//    onEditingChanged: console.log("editing", editing)

    signal rowHeightChanged(int row, real height)

    function newTask() {
        var idx = mainController.newTask('', taskListView.currentIndex)
        currentRow = idx
        editCurrentTask()
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
            var idx = taskListView.currentIndex
            console.log("deleting tasks %1".arg(getSelectedIndexes()))
            mainController.deleteTasks(getSelectedIndexes())
            if ( idx >= taskListView.rowCount ) {
                idx = taskListView.rowCount -1
            }
            taskListView.selection.select(idx)
            taskListView.currentRow = idx
        }
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
        height: 30
        color: {
           var baseColor = styleData.alternate?Theme.activePalette.alternateBase:Theme.activePalette.base
           return styleData.selected?Theme.activePalette.highlight:baseColor
        }
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            acceptedButtons: Qt.RightButton
            onClicked: contextMenu.popup()
        }
        Connections {
            target: listView
            onRowHeightChanged: {
                if (styleData.row === row) rect.height = height
            }
        }
     }

    TableViewColumn {
        role: "html"
        delegate: TaskLine {

            current: (listView.currentRow === styleData.row)
            onCurrentChanged: {
                if (current) listView.currentItem = this
            }
            onHeightChanged: {
                listView.rowHeightChanged(styleData.row, height)
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

