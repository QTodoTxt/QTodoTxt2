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
        property alias window_width: window.width
        property alias window_height: window.height
    }
//    MainController {
//        id: mainController
//    }

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
        onTriggered: {        }
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
        id: showSearchAction
        iconName: "search"
        text: qsTr("Show Search Field")
        shortcut: "Ctrl+F"
        checkable: true
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
            MenuSeparator {}
            MenuItem { action: editCompleteTasks}
        }
        Menu {
            title: qsTr("View")
            MenuItem { action: showSearchAction}
        }
        Menu {
            title: qsTr("Help")
            MenuItem { action: helpShowAbout }
            MenuItem { action: helpShowShortcuts }
        }
    }

    toolBar: ToolBar {
        RowLayout {
            anchors.fill: parent
            MenuSeparator{}
            ToolButton { action: fileOpen }
            ToolButton { action: fileSave }
            //ToolBarSeparator { }
            ToolButton { action: editNewTask }
            ToolButton { action: editEditTask }
            //ToolButton { action:  mainController.actions['showSearchAction']}
            Item { Layout.fillWidth: true }
        }
    }

    FileDialog {
        id: fileDialog
        nameFilters: ["Text files (*.txt)"]
        onAccepted: {
            if (fileDialog.selectExisting)
                document.fileUrl = fileUrl //FIXME
            else
                document.saveAs(fileUrl, selectedNameFilter) //FIXME
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
            Settings {
                property alias filters_tree_width: filtersTree.width
            }
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
                visible: showSearchAction.checked
                placeholderText: "Search"
                Keys.onPressed: {
                    mainController.searchText = text
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
