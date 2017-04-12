import QtQuick 2.2

ListModel {
    property var sourceModel: []
    property string completionPrefix: ""
    property int cursorPosition: 0

    onCompletionPrefixChanged: {

    }

    onSourceModelChanged: {
        sourceModel.forEach(function(i){
        append({"text": i})
        })
    }
}
