import QtQuick 2.2

ListModel {
    property var sourceModel: []
    property string completionPrefix: ""

    onCompletionPrefixChanged: {

    }

    onSourceModelChanged: {
        sourceModel.forEach(function(i){
        append({"text": i})
        })
    }
}
