import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQml 2.2

MenuBar {
    Menu {
        title: qsTr("File")
        MenuItem { action: actions.fileNew }
        MenuItem { action: actions.fileOpen}
        Menu {
            id: recentMenu
            title: qsTr("Recent Files")
            Instantiator {
                model: mainController.recentFiles
                onObjectAdded: recentMenu.insertItem(index, object)
                onObjectRemoved: recentMenu.removeItem( object )
                delegate: MenuItem {
                    text: (mainController.recentFiles[model.index] ? mainController.recentFiles[model.index] : "")
                    onTriggered: mainController.open(mainController.recentFiles[model.index])
                }
            }
        }

        MenuItem { action: actions.fileSave }
        MenuSeparator {}
        MenuItem {
            text: qsTr("Preferences")
            iconName: "configure"
            onTriggered: {
                var component = Qt.createComponent("Preferences.qml")
                var dialog = component.createObject(component.prefWindow)
                dialog.open()
            }
        }
        MenuSeparator {}
        MenuItem { action: actions.quitApp}
        //FIXME: if you want you can play around with the style in ./style/dark_blue/MenuStyle.qml
        //style: MyStyle.MenuStyle{}
    }
    Menu {
        title: qsTr("Edit")
        MenuItem { action: actions.newTask }
        MenuItem { action: actions.editTask }
        MenuItem { action: actions.deleteTask }
        MenuSeparator {}
        MenuItem { action: actions.completeTasks}
        MenuSeparator {}
        MenuItem { action: actions.increasePriority}
        MenuItem { action: actions.decreasePriority}
    }
    Menu {
        title: qsTr("View")
        MenuItem { action: actions.showSearchAction}
        MenuItem { action: actions.showFilterPanel}
        MenuItem { action: actions.showToolBarAction}
        MenuItem { action: actions.showCompleted}
        MenuItem { action: actions.showFuture}
    }
    Menu {
        title: qsTr("Sorting")
        MenuItem { action: actions.sortTodoTxt}
        MenuItem { action: actions.sortCreationDate}
        MenuItem { action: actions.sortDueDate}
    }
    Menu {
        title: qsTr("Help")
        MenuItem { action: actions.helpShowAbout }
        MenuItem { action: actions.helpShowShortcuts }
    }
}
