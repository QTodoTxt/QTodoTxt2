import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.1
import QtQml 2.2
import QtQml.Models 2.2
import Qt.labs.settings 1.0

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
        onFiltersUpdated: {
            console.log("MODEL, changed", filtersTree.model.rowCount())
            filtersTree.expandAll()
        }
    }

    Settings {
        category: "WindowState"
        property alias window_width: window.width
        property alias window_height: window.height
        property alias filters_tree_width: filtersTree.width
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

    Actions {
        id: actions
    }

    menuBar: MainMenu { }

    toolBar: MainToolBar {
        visible: actions.showToolBarAction.checked
    }


    MessageDialog {
        id: confirmDialog
        title: "QTodotTxt Confirm"
        text: "Do you really want to delete current task" 
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            var idx = taskListView.currentIndex
            mainController.deleteTask(taskListView.currentIndex)
            if ( idx > 0 ) { taskListView.currentIndex = idx - 1 }
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

    SystemPalette {
        id: systemPalette
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

            visible: actions.showFilterPanel.checked
            alternatingRowColors: false

            rowDelegate: Rectangle {
                color: systemPalette.highlight
                opacity: (styleData.selected ? 0.5 : 0)
            }
            /*

            itemDelegate: Row {
                spacing: 5
                Image {
                    source: ( mainController.filtersModel.iconFromIndex(styleData.index) !== "" ?
                                 window.theme + mainController.filtersModel.iconFromIndex(styleData.index) : "")
                    height: filterLbl.height
                    fillMode: Image.PreserveAspectFit
                }
                Label {
                    id: filterLbl
                    text: styleData.value
                }
            }
            */

            model: mainController.filtersModel
            selection: ItemSelectionModel {
                model: mainController.filtersModel
            }

            selectionMode: SelectionMode.ExtendedSelection

            TableViewColumn {
                title: "Filters"
                role: "display"
            }

            TableViewColumn {
                title: "Total"
                role: "totalCount"
            }

            TableViewColumn {
                title: "Completed"
                role: "completedCount"
            }

            onActivated: {
                //FIXME: check all current select items, is multi selction is allowed
                mainController.filterRequest(index)
                console.log("ACTI", filtersTree.isExpanded(filtersTree.currentIndex))
                filtersTree.expand(filtersTree.currentIndex)
            }

            function expandAll() {
                var rootChildren = model.getRootChildren()
                for (var i=0; i < rootChildren.length ; i++) {
                    filtersTree.expand(rootChildren[i])
                }
            }
        }

        ColumnLayout {
            Layout.minimumWidth: 50
            Layout.fillWidth: true


            TextField {
                id: searchField

                Layout.fillWidth: true

                visible: actions.showSearchAction.checked
//                focus: true

                placeholderText: "Search"
                onTextChanged: {
                    mainController.searchText = text
                    searchField.focus = true
                }

                CompletionPopup { completerParent: splitView }

            }

            TaskListView {
                id: taskListView
                Layout.fillHeight: true
                Layout.fillWidth: true

                taskList: mainController.filteredTasks
            }
        }

    }
}
