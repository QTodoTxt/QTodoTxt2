import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQml.Models 2.2

import Theme 1.0

TreeView {
    id: treeView
    alternatingRowColors: false

    rowDelegate: Rectangle {
        color: systemPalette.highlight
        opacity: (styleData.selected ? 0.5 : 0)
        height: 3*Theme.mediumSpace
    }

    model: mainController.filtersModel
    selectionMode: SelectionMode.ExtendedSelection
    selection: ItemSelectionModel {
        model: mainController.filtersModel
        onSelectedIndexesChanged: {
            console.log(selectedIndexes)
            mainController.filterByIndexes(selectedIndexes)
        }
    }


    TableViewColumn {
        id: filterNameCol
        width: treeView.width - totalCol.width - completedCol.width
        resizable: false

        title: "Filters"
        role: "display"
        delegate: Row {
            spacing: Theme.smallSpace
            height: lbl.implicitHeight + Theme.mediumSpace
            width: filterNameCol.width
            Image {
                id: img
                source: Theme.iconSource(mainController.filtersModel.iconFromIndex(styleData.index))
                height: lbl.height
                fillMode: Image.PreserveAspectFit
            }
            Label {
                id: lbl
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - img.width

                text: /*mainController.filtersModel.iconFromIndex(styleData.index)+ */styleData.value
                elide: styleData.elideMode
            }
        }
    }

    TableViewColumn {
        id: totalCol
        width: 50
//        resizable: false

        title: "Tot."
        role: "totalCount"
    }

    TableViewColumn {
        id: completedCol
        width: 50
//        resizable: false

        title: "Compl."
        role: "completedCount"
    }

    onClicked: {
        selection.select(index, ItemSelectionModel.Select | ItemSelectionModel.Current)
    }
    
    onChildrenChanged: {
        console.log("children")
        Qt.callLater(expandAll())
    }

    function resizeCountCols() {
        totalCol.resizeToContents()
        completedCol.resizeToContents()
    }

    function expandAll() {
        var rootChildren = model.getRootChildren()
        for (var i=0; i < rootChildren.length ; i++) {
            treeView.expand(rootChildren[i])
        }
    }
}
