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
    }

    property Action fileNew: Action{
            //id:fileNew
            iconName: "document-new"
            text: qsTr("New")
            //shortcut: StandardKey.New
            onTriggered: {        }
    }

    property Action fileOpen: Action {
//        id: fileOpen
        iconName: "document-open"
        text: qsTr("Open")
        shortcut: StandardKey.Open
        onTriggered: {
            fileDialog.selectExisting = true
            fileDialog.open()
        }
    }

    property Action fileSave: Action{
        //id:fileSave
        iconName: "document-save"
        text: qsTr("Save")
        shortcut: StandardKey.Save
        onTriggered: mainController.save()
    }

    property Action fileSaveAs: Action{
        //id:fileSaveAs
        iconName: "document-save-as"
        text: qsTr("Save As")
        shortcut: StandardKey.SaveAs
        onTriggered: {
            fileDialog.selectExisting = false
            fileDialog.open()
        }
    }

    property Action quitApp: Action{
        //id:quitApp
        iconName: "application-exit"
        text: qsTr("Exit")
        shortcut: StandardKey.Quit
        onTriggered: appWindow.close()
    }

    property Action newTask: Action{
        //id:newTask

        iconName: "list-add"
        iconSource: Theme.iconSource(iconName) //appWindow.theme + "TaskCreate.png"
        text: qsTr("Create New Task")

        shortcut: "Ins"|StandardKey.New
        onTriggered: {
            var idx = mainController.newTask('', taskListView.currentIndex)
            taskListView.currentIndex = idx
            taskListView.editCurrentTask()
        }
    }

    property Action deleteTask: Action{
        //id:deleteTask

        iconName: "list-remove"
        iconSource: Theme.iconSource(iconName)

        text: qsTr("Delete Task")
        shortcut: "Del"
        onTriggered: confirmDialog.open()
    }

    property Action editTask: Action{
        //id:editTask

        iconName: "document-edit"
        iconSource: appWindow.theme + "TaskEdit.png"

        text: qsTr("Edit Task")
        shortcut: "Ctrl+E"
        enabled: taskListView.currentIndex > -1
        onTriggered: { taskListView.editCurrentTask() }
    }

    property Action completeTasks: Action{
        //id:completeTasks
        iconName: "checkmark"
        iconSource: Theme.iconSource(iconName)

        text: qsTr("Complete Task")
        shortcut: "X"
        onTriggered: {
            var idx = taskListView.currentIndex
            taskListView.model[taskListView.currentIndex].toggleCompletion()
            //if (  ( !showCompleted.checked )  && idx > 0) { taskListView.currentIndex = idx -1 }
            if (idx > 0) { taskListView.currentIndex = idx -1 }
        }
    }

    property Action increasePriority: Action{
        //id:increasePriority
        iconName: "arrow-up"
        iconSource: Theme.iconSource(iconName)

        text: qsTr("Increase Priority")
        shortcut: "+"
        onTriggered: {
            taskListView.model[taskListView.currentIndex].increasePriority()
        }
    }

    property Action decreasePriority: Action{
        //id:decreasePriority
        iconName: "arrow-down"
        iconSource: Theme.iconSource(iconName)

        text: qsTr("Decrease Priority")
        shortcut: "-"
        onTriggered: {
            taskListView.model[taskListView.currentIndex].decreasePriority()
        }
    }

    property Action showSearchAction: Action{
        id:showSearchAction
        iconName: "search"
        iconSource: Theme.iconSource(iconName)

        text: qsTr("Show Search Field")
        shortcut: "Ctrl+F"
        checkable: true
    }

    property Action showFilterPanel: Action{
        id:showFilterPanel
        iconName: "view-filter"
        iconSource: Theme.iconSource(iconName)

        text: qsTr("Show Filter Panel")
        //        shortcut: "Ctrl+T"
        checkable: true
        checked: true
    }

    property Action showToolBarAction: Action{
        id:showToolBarAction
        iconName: "configure-toolbars"
        iconSource: Theme.iconSource(iconName)

        text: qsTr("Show ToolBar")
        shortcut: "Ctrl+T"
        checkable: true
        checked: true
    }

    property Action showCompleted: Action{
        id:showCompleted
        iconName: "show-completed"
        iconSource: Theme.iconSource(iconName)

        text: qsTr("Show Completed Tasks")
        shortcut: "Ctrl+C"
        checkable: true
        checked: false
        onToggled: mainController.showCompleted = checked
    }

    property Action showFuture: Action{
        id:showFuture
        iconName: "future"
        iconSource: Theme.iconSource(iconName)

        text: qsTr("Show Future Tasks")
        shortcut: "Ctrl+F"
        checkable: true
        checked: true
        onToggled: mainController.showFuture = checked
    }

    property Action archive: Action{
        //id:archive
        iconName: "archive"
        iconSource: Theme.iconSource(iconName)

        text: qsTr("Archive Completed Tasks")
        shortcut: "Ctrl+A"
        onTriggered: mainController.archiveCompletedTasks()
    }

    property Action addLink: Action{
        //id:addLink
        iconName: "addLink"
        iconSource: Theme.iconSource(iconName)

        text: qsTr("Add link to current task")
        shortcut: "Ctrl+L"
        onTriggered: linkDialog.open()
    }

    property Action helpShowAbout: Action{
        //id:helpShowAbout
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
        //id:helpShowShortcuts
        iconName: "help-about"
        text: qsTr("Shortcuts list");
        shortcut: "Ctrl+F1"
        onTriggered: aboutBox.open()
    }

    property Action sortTodoTxt: Action{
        //id:sortTodoTxt
        iconName: "view-sort-ascending-symbolic"
        text: "todo.txt" //FIXME better text for sorting like in todo.txt file
    }

    property Action sortCreationDate: Action{
        //id:sortCreationDate
        iconName: "view-sort-ascending-symbolic"
        text: "Creation Date"
    }

    property Action sortDueDate: Action{
        //id:sortDueDate
        iconName: "view-sort-ascending-symbolic"
        text: "Due Date"
    }



    FileDialog {
        //FIXME set default folder!
            id: fileDialog
            nameFilters: ["Text files (*.txt)"]
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
        //nameFilters: ["Text files (*.txt)"]
        selectExisting: false
        onAccepted: {
            taskListView.model[taskListView.currentIndex].text += ' '
            taskListView.model[taskListView.currentIndex].text += fileUrl.toString()
        }
    }
}

