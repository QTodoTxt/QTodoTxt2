import QtQuick 2.7
import QtQuick.Controls 1.4

ListView {
    id: listView
    property var taskList

    function editCurrentTask() {
        if (currentItem !== null) {
            currentItem.state = "edit"
        }
    }

    spacing: 10
    highlight: Rectangle {
        color: systemPalette.highlight
        opacity: 0.5
    }
    //workaround for issue #10 dont know how to turn off animations:
    highlightMoveDuration: 0

    focus: true
    Keys.onReturnPressed: listView.currentItem.state = "edit"

    model: taskList
    delegate: TaskLine {
        width: listView.width

        text: taskList[model.index].text
        html: taskList[model.index].html
        priority: taskList[model.index].priorityHtml

        current: (currentIndex === model.index)

        onActivated: listView.currentIndex = model.index
        onShowContextMenu: contextMenu.popup()
        onStateChanged: if (state === "show") listView.focus = true
        onInputAccepted: {
            console.log("new text: ", newText)
            taskList[model.index].text = newText
        }
    }

    Menu {
        id: contextMenu
        MenuItem { action: actions.newTask }
        MenuItem { action: actions.editTask }
    }
}

