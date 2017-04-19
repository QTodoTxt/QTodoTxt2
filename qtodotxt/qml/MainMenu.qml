import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQml 2.2

MenuBar {
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
        MenuItem { action: fileRevert }
        MenuSeparator {}
        MenuItem {
            text: qsTr("Preferences")
            iconName: "configure"
            onTriggered: {
                var component = Qt.createComponent("Preferences.qml")
                var dialog = component.createObject(window)
                dialog.open()
            }
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
