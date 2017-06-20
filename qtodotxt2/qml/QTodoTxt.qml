import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.1
import QtQml 2.2
import QtQml.Models 2.2
import Qt.labs.settings 1.0

import Theme 1.0

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1024
    height: 768
    title: mainController.title

    Connections {
        target: mainController
        onError: {
            errorDialog.text = msg
            errorDialog.open()
        }
        onFileExternallyModified: {
            reloadDialog.open()
        }
        onFiltersUpdated: {
            filtersTree.expandAll()
        }
    }

    Settings {
        category: "WindowState"
        property alias window_x: appWindow.x
        property alias window_y: appWindow.y
        property alias window_width: appWindow.width
        property alias window_height: appWindow.height
        property alias filters_tree_width: filtersTree.width
    }

    onClosing: {
        if ( mainController.canExit() ) {
            close.accepted = true
        } else {
            close.accepted = false
            confirmExitDialog.open()
        }
    }

    Actions {
        id: actions
    }

    menuBar: MainMenu { }

    toolBar: MainToolBar {
        visible: actions.showToolBarAction.checked
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
    }

    MessageDialog {
        id: confirmExitDialog
        title: "File not saved"
        icon: StandardIcon.Question
        text: "Your todo.txt file is not saved. Do you want to force exit?"
        standardButtons: StandardButton.Yes | StandardButton.No | StandardButton.Cancel
        onYes: {
            Qt.quit()
        }
    }

    SystemPalette {
        id: systemPalette
    }

    SplitView {
        id: splitView
        anchors.fill: parent
        orientation: Qt.Horizontal


        FilterView {
            id: filtersTree
            Layout.minimumWidth: 150
            Layout.fillHeight: true

            visible: actions.showFilterPanel.checked
        }

        ColumnLayout {
            Layout.minimumWidth: 50
            Layout.fillWidth: true


            TextField {
                id: searchField

                Layout.fillWidth: true

                visible: actions.showSearchAction.checked

                placeholderText: "Search"
                onTextChanged: {
                    mainController.searchText = text
                    searchField.focus = true
                }

                CompletionPopup { }
            }

            TaskListTableView {
                id: taskListView
                Layout.fillHeight: true
                Layout.fillWidth: true

                taskList: mainController.filteredTasks
            }
        }
    }
    Component.onDestruction: {
        taskListView.quitEditing()
    }
}
