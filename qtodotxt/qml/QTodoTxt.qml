import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.1
import QtQml 2.2
import QtQml.Models 2.2
import Qt.labs.settings 1.0

//import QTodoTxt 1.0
import "./styles/dark_blue" as MyStyle

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 768
    title: mainController.title
    property string theme: "qrc:///dark_icons/resources/"

    Connections {
        target: mainController
        onError: {
            errorDialog.text = msg
            errorDialog.open()
        }
        onFileExternallyModified: {
            reloadDialog.open()
        }
    }

    Settings {
        category: "WindowState"
        property alias window_width: window.width
        property alias window_height: window.height
        property alias filters_tree_width: filtersTree.width
    }

    Settings {
        category: "VisibleWidgets"
        property alias search_field_visible: showSearchAction.checked
        property alias toolbar_visible: showToolBarAction.checked
        property alias filter_panel_visible: showFilterPanel.checked
        property alias show_completed: showCompleted.checked
        property alias show_future: showFuture.checked
    }

    //    MainController {
    //        id: mainController
    //    }

    onClosing: {
        if ( mainController.canExit() ) {
            close.accepted = true
        } else {
            console.log("State of document is ", mainController.canExit())
            console.log("FIXME: popup dialog and sav as for saving")
        }
    }

    SystemPalette {
        id: systemPalette
    }

    AboutBox {
        id: aboutBox
        appName: "QTodoTxt"
    }

    Preferences {
        id: preferencesWindow
    }

    Action {
        id: fileNew
        iconName: "document-new"
        text: qsTr("New")
        shortcut: StandardKey.New
        onTriggered: {        }
    }

    Action {
        id: fileOpen
        iconName: "document-open"
        text: qsTr("Open")
        shortcut: StandardKey.Open
        onTriggered: {
            fileDialog.selectExisting = true
            fileDialog.open()
        }
    }

    Action {
        id: fileSave
        iconName: "document-save"
        text: qsTr("Save")
        shortcut: StandardKey.Save
        onTriggered: mainController.save()
    }

    Action {
        id: fileSaveAs
        iconName: "document-save-as"
        text: qsTr("Save As")
        shortcut: StandardKey.SaveAs
        onTriggered: {
            fileDialog.selectExisting = false
            fileDialog.open()
        }
    }


    Action {
        id: fileRevert
        iconName: "document-revert"
        text: qsTr("Revert")
        onTriggered: {        }
    }

    Action {
        id: quitApp
        iconName: "application-exit"
        text: qsTr("Exit")
        shortcut: StandardKey.Quit 
        onTriggered: exit()
    }


    Action {
        id: newTask
        iconName: "list-add"
        iconSource: window.theme + "TaskCreate.png"
        text: qsTr("Create New Task")
        shortcut: "Ins"|StandardKey.New
        onTriggered: {
            var idx = mainController.newTask('', taskListView.currentIndex)
            taskListView.currentIndex = idx
            taskListView.editCurrentTask()
        }
    }

    Action {
        id: deleteTask
        iconName: "edit-delete-symbolic"
        text: qsTr("Delete Task")
        shortcut: "Del"
        onTriggered: confirmDialog.open()
    }

    Action {
        id: editTask
        iconName: "document-edit"
        iconSource: window.theme + "TaskEdit.png"
        text: qsTr("Edit Task")
        shortcut: "Ctrl+E"
        enabled: taskListView.currentIndex > -1
        onTriggered: { taskListView.editCurrentTask() }
    }

    Action {
        id: completeTasks
        iconName: "checkmark"
        iconSource: window.theme + "TaskComplete.png"
        text: qsTr("Complete Task")
        shortcut: "X"
        onTriggered: {
            taskListView.model[taskListView.currentIndex].toggleCompletion()
        }
    }

    Action {
        id: increasePriority
        iconName: "arrow-up"
        iconSource: window.theme + "TaskPriorityIncrease.png"
        text: qsTr("Increase Priority")
        shortcut: "+"
        onTriggered: {
            taskListView.model[taskListView.currentIndex].increasePriority()
        }
    }

    Action {
        id: decreasePriority
        iconName: "arrow-down"
        iconSource: window.theme + "TaskPriorityDecrease.png"
        text: qsTr("Decrease Priority")
        shortcut: "-"
        onTriggered: {
            taskListView.model[taskListView.currentIndex].decreasePriority()
        }
    }

    Action {
        id: showSearchAction
        iconName: "search"
        iconSource: window.theme + "ActionSearch.png"
        text: qsTr("Show Search Field")
        shortcut: "Ctrl+F"
        checkable: true
    }

    Action {
        id: showFilterPanel
        iconName: "view-filter"
        iconSource: window.theme + "sidepane.png"
        text: qsTr("Show Filter Panel")
        //        shortcut: "Ctrl+T"
        checkable: true
        checked: true
    }

    Action {
        id: showToolBarAction
        iconName: "configure-toolbars"
        text: qsTr("Show ToolBar")
        shortcut: "Ctrl+T"
        checkable: true
        checked: true
    }

    Action {
        id: showCompleted
        //iconName: "search"
        iconSource: window.theme + "show_completed.png"
        text: qsTr("Show Completed Tasks")
        shortcut: "Ctrl+C"
        checkable: true
        checked: false
        onToggled: mainController.showCompleted = checked
    }

    Action {
        id: showFuture
        //iconName: "search"
        iconSource: window.theme + "future.png"
        text: qsTr("Show Future Tasks")
        shortcut: "Ctrl+F"
        checkable: true
        checked: true
        onToggled: mainController.showFuture = checked
    }

    Action {
        id: archive
        //iconName: "search"
        iconSource: window.theme + "archive.png"
        text: qsTr("Archive Completed Tasks")
        shortcut: "Ctrl+A"
        onTriggered: mainController.archiveCompletedTasks()
    }

    Action {
        id: addLink
        //iconName: "search"
        iconSource: window.theme + "link.png"
        text: qsTr("Add link to current task")
        shortcut: "Ctrl+L"
        onTriggered: linkDialog.open()
    }

    Action {
        id: helpShowAbout
        iconName: "help-about"
        text: qsTr("About");
        shortcut: "F1"
        onTriggered: aboutBox.open()
    }

    Action {
        id: helpShowShortcuts
        iconName: "help-about"
        text: qsTr("Shortcuts list");
        shortcut: "Ctrl+F1"
        onTriggered: aboutBox.open()
    }

    Action {
        id: sortTodoTxt
        iconName: "view-sort-ascending-symbolic"
        text: "todo.txt" //FIXME better text for sorting like in todo.txt file
    }

    Action {
        id: sortCreationDate
        iconName: "view-sort-ascending-symbolic"
        text: "Creation Date"
    }

    Action {
        id: sortDueDate
        iconName: "view-sort-ascending-symbolic"
        text: "Due Date"
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem { action: fileNew }
            MenuItem { action: fileOpen}
            Menu {
                id: recentMenu
                title: qsTr("Recent Files")
                Instantiator {
                    model: mainController.recentFiles
                    onObjectAdded: recentMenu.insertItem(index, object)
                    onObjectRemoved: recentMenu.removeItem( object )
                    delegate: MenuItem {
                        text: mainController.recentFiles[model.index]
                        onTriggered: mainController.open(mainController.recentFiles[model.index])
                    }
                }
            }

            MenuItem { action: fileSave }
            MenuItem { action: fileSaveAs }
            //MenuItem { action: fileRevert }
            MenuSeparator {}
            MenuItem {
                text: qsTr("Preferences")
                iconName: "configure"
                onTriggered: preferencesWindow.show()
            }
            MenuSeparator {}
            MenuItem { action: quitApp}
            //FIXME: if you want you can play around with the style in ./style/dark_blue/MenuStyle.qml
            //style: MyStyle.MenuStyle{}
        }
        Menu {
            title: qsTr("Edit")
            MenuItem { action: newTask }
            MenuItem { action: editTask }
            MenuItem { action: deleteTask }
            MenuSeparator {}
            MenuItem { action: completeTasks}
            MenuSeparator {}
            MenuItem { action: increasePriority}
            MenuItem { action: decreasePriority}
        }
        Menu {
            title: qsTr("View")
            MenuItem { action: showSearchAction}
            MenuItem { action: showFilterPanel}
            MenuItem { action: showToolBarAction}
            MenuItem { action: showCompleted}
            MenuItem { action: showFuture}
        }
        Menu {
            title: qsTr("Sorting")
            MenuItem { action: sortTodoTxt}
            MenuItem { action: sortCreationDate}
            MenuItem { action: sortDueDate}
        }
        Menu {
            title: qsTr("Help")
            MenuItem { action: helpShowAbout }
            MenuItem { action: helpShowShortcuts }
        }
    }

    toolBar: ToolBar {
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

    FileDialog {
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

    MessageDialog {
        id: confirmDialog
        title: "QTodotTxt Confirm"
        text: "Do you really want to delete current task" 
        standardButtons: StandardButton.Yes | StandardButton.No | StandardButton.Cancel
        onAccepted: {
            mainController.deleteTask(taskListView.currentIndex)
        }
    }

    MessageDialog {
        id: errorDialog
        title: "QTodotTxt Error"
        text: "Error message should be here!"
    }

    MessageDialog {
        id: reloadDialog
        title: "File externally modified"
        icon: StandardIcon.Question
        text: "Your todo.txt file has been externally modified. Reload newer version?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: mainController.reload() 
        //onNo: console.log("didn't copy")
    }

    SplitView {
        id: splitView
        anchors.fill: parent
        orientation: Qt.Horizontal

        TreeView {
            id: filtersTree
            width: 250
            Layout.minimumWidth: 150
            Layout.fillHeight: true
            visible: showFilterPanel.checked

            model: mainController.filtersModel
            selection: ItemSelectionModel {
                model: mainController.filtersModel
            }

            selectionMode: SelectionMode.ExtendedSelection
            TableViewColumn {
                title: "Filters"
                role: "display"
            }
            onClicked: {
                mainController.filterRequest(index)
            }
            onActivated: {
                //FIXME: check all current select items, is multi selction is allowed
                mainController.filterRequest(index)
            }
        }

        ColumnLayout {
            Layout.minimumWidth: 50
            Layout.fillWidth: true


            TextField {
                Layout.fillWidth: true
                id: searchField
                visible: showSearchAction.checked
                placeholderText: "Search"
                onTextChanged: {
                    mainController.searchText = text
                    searchField.focus = true
                }

                onActiveFocusChanged: console.log("active")
            }

            TaskListView {
                id: taskListView
                Layout.fillHeight: true
                Layout.fillWidth: true

                taskList: mainController.filteredTasks
            }
        }

    }
    CompletionPopup {
        id: completionPopup
//        textItem: searchField
    }
}
