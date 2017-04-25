import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQml.Models 2.2


TreeView {
    id: treeView
    alternatingRowColors: false

    rowDelegate: Rectangle {
        color: systemPalette.highlight
        opacity: (styleData.selected ? 0.5 : 0)
    }

    model: mainController.filtersModel
    selectionMode: SelectionMode.ExtendedSelection
    selection: ItemSelectionModel {
        model: mainController.filtersModel
        onSelectedIndexesChanged: {
            console.log(selectedIndexes)
//            mainController.filtersRequest(selectedIndexes)
        }

    }


    TableViewColumn {
        width: treeView.width - totalCol.width - completedCol.width
        resizable: false

        title: "Filters"
        role: "display"
        delegate: Row {
            spacing: 5
            Image {
                source: (mainController.filtersModel.iconFromIndex(styleData.index) !== "" ?
                             appWindow.theme + mainController.filtersModel.iconFromIndex(styleData.index) : "")
                height: filterLbl.height
                fillMode: Image.PreserveAspectFit
            }
            Label {
                id: filterLbl
                text: styleData.value
            }
        }
    }

    TableViewColumn {
        id: totalCol
        width: 50
        resizable: false

        title: "Tot."
        role: "totalCount"
    }

    TableViewColumn {
        id: completedCol
        width: 50
        resizable: false

        title: "Compl."
        role: "completedCount"
    }

//    onActivated: { //in Windows this means you need to doubleClick
    onClicked: {
        //FIXME: check all current select items, is multi selction is allowed
        console.log("ACTI", treeView.isExpanded(treeView.currentIndex))
        mainController.filterRequest(index) //This should be called from ItemSelectionModel
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
