import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton { action: actions.showSearchAction}
            ToolButton { action: actions.showFilterPanel}
            ToolButton { action: actions.showCompleted}
            ToolBarSeparator { }
            ToolButton { action: actions.fileSave }
            ToolBarSeparator { }
            ToolButton { action: actions.newTask }
            ToolButton { action: actions.newTaskFrom }
            ToolButton { action: actions.editTask }
            ToolButton { action: actions.deleteTask }
            ToolButton { action: actions.completeTasks}
            ToolBarSeparator { }
            ToolButton { action: actions.increasePriority}
            ToolButton { action: actions.decreasePriority}
            ToolBarSeparator { }
            ToolButton { action: actions.archive}
            ToolBarSeparator { }
            ToolButton { action: actions.addLink}
            Item { Layout.fillWidth: true }
        }
    }
