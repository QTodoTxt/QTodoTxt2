import QtQuick 2.7
import QtQuick.Controls 1.4

import Theme 1.0

TableView {

    //TODO contextmenu?
    //TODO MouseArea propagateEvents not working properly?
    //TODO lineheight via rowDelegate??
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
                console.log("rhc", row, height)
                if (styleData.row === row) rect.height = height
            }
        }
     }

    TableViewColumn {
        role: "html"
        delegate: TaskLine {
            width: listView.width

            text: taskList[styleData.row].text
            html: styleData.value //taskList[styleData.row].html

            current: (listView.currentRow === styleData.row)
            onCurrentChanged: {
                console.log("current", current, styleData.row)
                if (current) listView.currentItem = this
            }

//            onShowContextMenu: contextMenu.popup()
            onHeightChanged: {
                console.log("rh", height)
                listView.rowHeightChanged(styleData.row, height)
            }
            onInputAccepted: {
                console.log("input acccepted text: ", newText)
                taskList[styleData.row].text = newText
            }
        }
    }

    onClicked: console.log("tv cl", row)
    onDoubleClicked: editCurrentTask()//console.log("tv dc", row)

    Menu {
        id: contextMenu
        MenuItem { action: actions.newTask }
        MenuItem { action: actions.editTask }
    }
}

