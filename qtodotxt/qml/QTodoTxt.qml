import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.1

ApplicationWindow {
    id: root
    visible: true
    width: 640
    height: 480
//    title: "QTodoTxt"

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
            //ToolButton { action:  mc.actions['showSearchAction']}
            Item { Layout.fillWidth: true }
        }
    }

    FileDialog {
        id: fileDialog
        nameFilters: ["Text files (*.txt)"]
        onAccepted: {
            if (fileDialog.selectExisting)
                document.fileUrl = fileUrl
            else
                document.saveAs(fileUrl, selectedNameFilter)
        }
    }

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal
        TreeView {
            id: filtersTree
            model: mc.filtersModel
            //color: "white"
            width: 150
            Layout.minimumWidth: 150
            Layout.fillHeight: true
            TableViewColumn {
                title: "Filters"
                role: "display"
            }

        }
        ColumnLayout {
            Layout.minimumWidth: 50
            Layout.fillWidth: true
            TextField {
                Layout.fillWidth: true
                visible: showSearchAction.checked
                placeholderText: "Search"
            }
            TaskListView {
                id: taskListView
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }

}
