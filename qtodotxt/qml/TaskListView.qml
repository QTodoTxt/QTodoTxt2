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

    SystemPalette {
        id: systemPalette
    }

    highlight:
        Rectangle {
        color: systemPalette.highlight
        opacity: 0.5
    }

    highlightFollowsCurrentItem: true
    spacing: 10
    focus: true

    Keys.onReturnPressed: {
        listView.currentItem.state = "edit"
    }
    Keys.onEscapePressed: {
    }
    model: taskList
    delegate: TaskLine {
        width: listView.width

        text: taskList[model.index].text
        html: taskList[model.index].html

        current: (currentIndex === model.index)

        onActivated: listView.currentIndex = model.index
        onShowContextMenu: contextMenu.popup()
        onStateChanged: if (state === "show") listView.focus = true
    }

    Menu {
        id: contextMenu
        MenuItem { action: editNewTask }
        MenuItem { action: editEditTask }
    }
}

