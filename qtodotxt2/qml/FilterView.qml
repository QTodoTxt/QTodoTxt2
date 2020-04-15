import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQml.Models 2.2
import Qt.labs.settings 1.0

//import Theme 1.0 as Theme

TreeView {
    id: treeView
    alternatingRowColors: false

    model: mainController.filtersModel
    selectionMode: SelectionMode.ExtendedSelection
    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
    selection: ItemSelectionModel {
        model: mainController.filtersModel
        onSelectedIndexesChanged: {
//            console.log(selectedIndexes)
            taskListView.storeSelection()
            mainController.filterByIndexes(selectedIndexes)
            taskListView.restoreSelection()
        }
    }

    Settings {
        category: "WindowState"
        property alias filter_name_column_width: filterNameCol.width
        property alias filter_total_column_width: totalCol.width
        property alias filter_completed_column_width: completedCol.width
    }


    TableViewColumn {
        id: filterNameCol

        title: "Filters"
        role: "display"
        delegate: Row {
            spacing: Theme.smallSpace
            height: lbl.implicitHeight + Theme.mediumSpace
            width: filterNameCol.width
            Image {
                id: img
                height: 16
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter

                source: Theme.iconSource(mainController.filtersModel.iconFromIndex(styleData.index))
            }
            Label {
                id: lbl
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - img.width

                text: */mainController.filtersModel.iconFromIndex(styleData.index)+/*styleData.value
                elide: styleData.elideMode
            }
        }
    }

    TableViewColumn {
        id: totalCol
        width: 50
        title: "Tasks"
        role: "totalCount"
    }

    TableViewColumn {
        id: completedCol
        width: 50
        title: "Completed"
        role: "completedCount"
    }

    onClicked: {
        selection.select(index, ItemSelectionModel.Select | ItemSelectionModel.Current)
    }
    
    function expandAll() {
        var rootChildren = model.getRootChildren()
        for (var i=0; i < rootChildren.length ; i++) {
            treeView.expand(rootChildren[i])
        }
    }
}


/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
