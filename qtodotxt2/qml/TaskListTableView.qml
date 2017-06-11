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

    signal rowHeightChanged(int row, real height)

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
            console.log("deleting tasks %1".arg(getSelectedIndexes()))
            var idxs = getSelectedIndexes()
            if ( idxs.length == 0 ) return
            mainController.deleteTasks(getSelectedIndexes())
            console.log(idxs.length -1, idxs[idxs.length -1], listView.model.length)
            if (idxs[idxs.length -1] < listView.model.length ) {
                console.log("SETTING indeX", idxs[idxs.length -1])
                listView.currentRow = idxs[idxs.length -1]
            } else {
                console.log("SETTING indeX 222", listView.model.length - 1)
                listView.currentRow = listView.model.length - 1
            }
        }
    }

    function getSelectedIndexes() {
        var indexes = []
        selection.forEach(function(rowIndex) {
            indexes.push(rowIndex);
        })
        return indexes;
    }

    selection.onSelectionChanged: console.log("sc", getSelectedIndexes());

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
//                console.log("rhc", row, height)
                if (styleData.row === row) rect.height = height
            }
        }
     }

    TableViewColumn {
        role: "html"
        delegate: TaskLine {
            //width: listView.width

            text: {
                if (taskList[styleData.row]) taskList[styleData.row].text;
                else ""
            }
            html: styleData.value //taskList[styleData.row].html

            current: (listView.currentRow === styleData.row)
            onCurrentChanged: {
//                console.log("current", current, styleData.row)
                if (current) listView.currentItem = this
            }
            onHeightChanged: {
//                console.log("rh", height)
                listView.rowHeightChanged(styleData.row, height)
            }
            onInputAccepted: {
//                console.log("input acccepted text: ", newText)
                taskList[styleData.row].text = newText
            }
        }
    }

//    onClicked: console.log("sc",getSelectionIndexes());
    onDoubleClicked: editCurrentTask()//console.log("tv dc", row)

    Menu {
        id: contextMenu
        MenuItem { action: actions.newTask }
        MenuItem { action: actions.editTask }
    }
}

