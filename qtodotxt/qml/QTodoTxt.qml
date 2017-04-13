import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.1
import QtQml.Models 2.2
import Qt.labs.settings 1.0

//import QTodoTxt 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 768
    title: mainController.title
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
    }
    //    MainController {
    //        id: mainController
    //    }

    onClosing: {
        console.log("Closing, modified is:", mainController.modified)
        if ( mainController.canExit() ) {
            close.accepted = true
        } else {
            console.log("FIXME: popup dialog and as for saving")
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
        onTriggered: {        }
    }

    Action {
        id: fileRevert
        iconName: "document-revert"
        text: qsTr("Revert")
        onTriggered: {        }
    }


    Action {
        id: editNewTask
        iconName: "list-add"
        text: qsTr("Create New Task")
        shortcut: "Ins"
        onTriggered: {
            var idx = mainController.newTask('', taskListView.currentIndex)
            taskListView.currentIndex = idx
            taskListView.editCurrentTask()
        }
    }

    Action {
        id: deleteTask
        iconName: "list-delete"
        text: qsTr("Delete Task")
        shortcut: "Del"
        onTriggered: {
            mainController.deleteTask(taskListView.currentIndex)
        }
    }

    Action {
        id: editEditTask
        iconName: "document-edit"
        text: qsTr("Edit Task")
        shortcut: "Ctrl+E"
        enabled: taskListView.currentIndex > -1
        onTriggered: { taskListView.editCurrentTask() }
    }

    Action {
        id: editCompleteTasks
        iconName: "document-edit"
        text: qsTr("Complete Selected Tasks")
        shortcut: "X"
        onTriggered: {        }
    }

    Action {
        id: editIncreasePriority
        iconName: "plus"
        text: qsTr("Increase Priority")
        shortcut: "+"
        onTriggered: {
            taskListView.model[taskListView.currentIndex].increasePriority()
        }
    }

    Action {
        id: editDecreasePriority
        iconName: "minus"
        text: qsTr("Decrease Priority")
        shortcut: "-"
        onTriggered: {
            taskListView.model[taskListView.currentIndex].decreasePriority()
        }
    }

    Action {
        id: showSearchAction
        iconName: "search"
        text: qsTr("Show Search Field")
        shortcut: "Ctrl+F"
        checkable: true
    }

    Action {
        id: showToolBarAction
        //iconName: "toolbar"
        text: qsTr("Show ToolBar")
        shortcut: "Ctrl+T"
        checkable: true
        checked: true
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

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem { action: fileNew }
            MenuItem { action: fileOpen}
            MenuItem { action: fileSave }
            MenuItem { action: fileRevert }
            MenuSeparator {}
            MenuItem {
                text: qsTr("Preferences")
                onTriggered: preferencesWindow.show()
            }
            MenuSeparator {}
            MenuItem { text: qsTr("Exit");  shortcut: "Alt+F4"}
        }
        Menu {
            title: qsTr("Edit")
            MenuItem { action: editNewTask }
            MenuItem { action: editEditTask }
            MenuItem { action: deleteTask }
            MenuSeparator {}
            MenuItem { action: editCompleteTasks}
            MenuSeparator {}
            MenuItem { action: editIncreasePriority}
            MenuItem { action: editDecreasePriority}
        }
        Menu {
            title: qsTr("View")
            MenuItem { action: showSearchAction}
            MenuItem { action: showToolBarAction}
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
            ToolButton { action: showToolBarAction}
            ToolBarSeparator { }
            ToolButton { action: fileOpen }
            ToolButton { action: fileSave }
            ToolBarSeparator { }
            ToolButton { action: editNewTask }
            ToolButton { action: editEditTask }
            ToolButton { action: deleteTask }
            ToolButton { action: editCompleteTasks}
            ToolBarSeparator { }
            ToolButton { action: editIncreasePriority}
            ToolButton { action: editDecreasePriority}
            Item { Layout.fillWidth: true }
        }
    }

    FileDialog {
        id: fileDialog
        nameFilters: ["Text files (*.txt)"]
        onAccepted: {
            if (fileDialog.selectExisting) {
                console.log("OPENING", fileUrl.toString())
                mainController.open(fileUrl.toString()) //FIXME file wont open
            } else {
                document.saveAs(fileUrl, selectedNameFilter) //FIXME
            }
        }
    }

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        TreeView {
            id: filtersTree
            model: mainController.filtersModel
            width: 250
            Layout.minimumWidth: 150
            Layout.fillHeight: true
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

            RowLayout {
                Layout.fillWidth: true
                Text { visible: false; text: "Sort by: " }
                Button { visible: false; text: "(A)" }
                Button { visible: false; text: "cDate" }
                Button { visible: false; text: "dueDate" }

                TextField {
                    Layout.fillWidth: true
                    id: searchField
                    visible: showSearchAction.checked
                    placeholderText: "Search"
                    onTextChanged: {
                        mainController.searchText = text
                        searchField.focus = true
                    }
                }
            }

            TaskListView {
                id: taskListView
                Layout.fillHeight: true
                Layout.fillWidth: true

                taskList: mainController.taskList
            }
        }

    }
}
