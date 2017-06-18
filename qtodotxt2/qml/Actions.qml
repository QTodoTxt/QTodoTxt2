import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.1
import Qt.labs.settings 1.0

import Theme 1.0

Item {
    id: actions

    Settings {
        category: "VisibleWidgets"
        property alias search_field_visible: showSearchAction.checked
        property alias toolbar_visible: showToolBarAction.checked
        property alias filter_panel_visible: showFilterPanel.checked
        property alias show_completed: showCompleted.checked
        property alias show_future: showFuture.checked
        property alias show_hidden: showHidden.checked
    }

    property Action fileNew: Action{
            iconName: "document-new"
            text: qsTr("New")
            //shortcut: StandardKey.New
            onTriggered: {        }
    }

    property Action fileOpen: Action {
        iconName: "document-open"
        text: qsTr("Open")
        shortcut: StandardKey.Open
        enabled: !taskListView.editing
        onTriggered: {
            fileDialog.selectExisting = true
            fileDialog.open()
        }
    }

    property Action fileSave: Action{
        iconName: "document-save"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Save")
        shortcut: StandardKey.Save
        enabled: !taskListView.editing
        onTriggered: mainController.save()
    }

    property Action fileSaveAs: Action{
        iconName: "document-save-as"
        text: qsTr("Save As")
        shortcut: StandardKey.SaveAs
        enabled: !taskListView.editing
        onTriggered: {
            fileDialog.selectExisting = false
            fileDialog.open()
        }
    }

    property Action quitApp: Action{
        iconName: "application-exit"
        text: qsTr("Exit")
        shortcut: StandardKey.Quit
        onTriggered: appWindow.close()
    }

    property Action newTask: Action{
        iconName: "list-add"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Create New Task")
        shortcut: "Ins"|StandardKey.New
        enabled: !taskListView.editing
        onTriggered: {
            taskListView.newTask('')
        }
    }

    property Action newTaskFrom: Action{
        iconName: "new-from"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Create New Task from Template")
        enabled: !taskListView.editing && taskListView.currentItem !== null
        onTriggered: {
            taskListView.newFromTask();
        }
    }

    property Action deleteTask: Action{
        iconName: "list-remove"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Delete Task")
        shortcut: "Del"
        enabled: !taskListView.editing && taskListView.currentItem !== null
        onTriggered: taskListView.deleteSelectedTasks()
    }

    property Action editTask: Action{
        iconName: "document-edit"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Edit Task")
        shortcut: "Ctrl+E"
        enabled: !taskListView.editing && taskListView.currentItem !== null
        onTriggered: { taskListView.editCurrentTask() }
    }

    property Action completeTasks: Action{
        iconName: "checkmark"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Complete Task")
        shortcut: "X"
        enabled: !taskListView.editing && taskListView.currentItem !== null
        onTriggered: {
            taskListView.storeSelection()
            mainController.completeTasks(taskListView.getSelectedIndexes())
            taskListView.restoreSelection()
        }
    }

    property Action increasePriority: Action{
        iconName: "arrow-up"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Increase Priority")
        shortcut: "+"
        enabled: !taskListView.editing && taskListView.currentItem !== null
        onTriggered: {
            taskListView.storeSelection()
            taskListView.currentItem.task.increasePriority()
            taskListView.restoreSelection()
        }
    }

    property Action decreasePriority: Action{
        iconName: "arrow-down"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Decrease Priority")
        shortcut: "-"
        enabled: !taskListView.editing && taskListView.currentItem !== null
        onTriggered: {
            taskListView.storeSelection()
            taskListView.currentItem.task.decreasePriority()
            taskListView.restoreSelection()
        }
    }

    property Action showSearchAction: Action{
        id: showSearchAction
        iconName: "search"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Show Search Field")
        shortcut: "Ctrl+F"
        checkable: true
    }

    property Action showFilterPanel: Action{
        id: showFilterPanel
        iconName: "view-filter"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Show Filter Panel")
        checkable: true
        checked: true
    }

    property Action showToolBarAction: Action{
        id: showToolBarAction
        iconName: "configure-toolbars"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Show ToolBar")
        shortcut: "Ctrl+T"
        checkable: true
        checked: true
    }

    property Action showCompleted: Action{
        id: showCompleted
        iconName: "show-completed"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Show Completed Tasks")
        shortcut: "Ctrl+C"
        checkable: true
        checked: false
        enabled: !taskListView.editing
        onToggled: {
            taskListView.storeSelection()
            mainController.showCompleted = checked
            taskListView.restoreSelection()
        }
    }

    property Action showFuture: Action{
        id: showFuture
        iconName: "future"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Show Future Tasks")
        shortcut: "Ctrl+F"
        checkable: true
        checked: true
        enabled: !taskListView.editing
        onToggled: {
            taskListView.storeSelection()
            mainController.showFuture = checked
            taskListView.restoreSelection()
        }
    }

    property Action showHidden: Action{
        id: showHidden
        iconName: "show-hidden"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Show Hidden Tasks")
        shortcut: "Ctrl+H"
        checkable: true
        checked: false
        enabled: !taskListView.editing
        onToggled: {
            taskListView.storeSelection()
            mainController.showHidden = checked
            taskListView.restoreSelection()
        }
    }

    property Action archive: Action{
        iconName: "archive"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Archive Completed Tasks")
        shortcut: "Ctrl+A"
        enabled: !taskListView.editing
        onTriggered: {
            taskListView.storeSelection()
            mainController.archiveCompletedTasks()
            taskListView.restoreSelection()
        }
    }

    property Action addLink: Action{
        iconName: "addLink"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("Add link to current task")
        shortcut: "Ctrl+L"
        enabled: !taskListView.editing && taskListView.currentItem !== null
        onTriggered: linkDialog.open()
    }

    property Action helpShowAbout: Action{
        iconName: "help-about"
        iconSource: Theme.iconSource(iconName)
        text: qsTr("About");
        shortcut: "F1"
        onTriggered: {
            var component = Qt.createComponent("AboutBox.qml")
            var dialog = component.createObject(appWindow)
            dialog.open()
        }
    }

    property Action helpShowShortcuts: Action{
        iconName: "help-about"
        text: qsTr("Shortcuts list");
        shortcut: "Ctrl+F1"
        onTriggered: aboutBox.open()
    }

    property Action sortDefault: Action{
        iconName: "view-sort-ascending-symbolic"
        text: "Default"
        enabled: !taskListView.editing
        onTriggered: {
            taskListView.storeSelection()
            mainController.sortingMode = "default"
            taskListView.restoreSelection()
        }
    }

    property Action sortByProjects: Action{
        iconName: "view-sort-ascending-symbolic"
        text: "Projects"
        enabled: !taskListView.editing
        onTriggered: {
            taskListView.storeSelection()
            mainController.sortingMode = "projects"
            taskListView.restoreSelection()
        }
    }

    property Action sortByContexts: Action{
        iconName: "view-sort-ascending-symbolic"
        text: "Contexts"
        enabled: !taskListView.editing
        onTriggered: {
            taskListView.storeSelection()
            mainController.sortingMode = "contexts"
            taskListView.restoreSelection()
        }
    }

    property Action sortByDueDate: Action{
        //id:sortDueDate
        iconName: "view-sort-ascending-symbolic"
        text: "Due Date"
        enabled: !taskListView.editing
        onTriggered: {
            taskListView.storeSelection()
            mainController.sortingMode = "due"
            taskListView.restoreSelection()
        }
    }

    FileDialog {
        id: fileDialog
        nameFilters: ["Text files (*.txt)"]
        folder: mainController.docPath
        onAccepted: {
            if (fileDialog.selectExisting) {
                mainController.open(fileUrl)
            } else {
                mainController.save(fileUrl)
            }
        }
    }

    FileDialog {
        id: linkDialog
        selectExisting: true
        onAccepted: {
            taskListView.storeSelection()
            taskListView.currentItem.task.text += ' ' + fileUrl.toString()
            taskListView.restoreSelection()
        }
    }
}

