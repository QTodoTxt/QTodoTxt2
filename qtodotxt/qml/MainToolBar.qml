import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

ToolBar {
        id: toobar
        visible: showToolBarAction.checked
        RowLayout {
            anchors.fill: parent
            ToolButton { action: showSearchAction}
            ToolButton { action: showFilterPanel}
            ToolButton { action: showCompleted}
            ToolButton { action: showFuture}
            ToolBarSeparator { }
            ToolButton { action: newTask }
            ToolButton { action: editTask }
            ToolButton { action: deleteTask }
            ToolButton { action: completeTasks}
            ToolBarSeparator { }
            ToolButton { action: increasePriority}
            ToolButton { action: decreasePriority}
            ToolBarSeparator { }
            ToolButton { action: archive}
            ToolBarSeparator { }
            ToolButton { action: addLink}
            Item { Layout.fillWidth: true }
        }
    }
