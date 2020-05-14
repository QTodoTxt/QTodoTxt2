import QtQuick 2.5
import QtQuick.Controls 1.4

Item {
    property QtObject completerParent: appWindow.contentItem
    property Item completer

    Connections {
        target: parent
        onActiveFocusChanged: {
            if (target.activeFocus) connectCompleter()
            else disconnectCompleter()
        }
    }

    //not used yet
    function findRootContentItem(c){
        console.log(c, typeof c, "on", c.objectName)
        if (c.toString().startsWith("Content")) {
            console.log("contenItem found", c)
            return c
        }
        else {
            if (c.parent !== null) return findRootContentItem(c.parent)
            else {
                console.log("no parent")
                return null
            }
        }
    }

    function createCompleter() {
        if (completer !== null) {
            console.log("Completer already there.")
            return false
        }
        completer = completerComp.createObject(completerParent)
        connectCompleter()
    }

    function connectCompleter() {
        completer.textItem = parent
        parent.Keys.forwardTo = [completer]
    }

    function disconnectCompleter() {
        completer.textItem = null
        parent.Keys.forwardTo = []
    }

    function destroyCompleter() {
        disconnectCompleter()
        completer.destroy()
    }

    Component.onCompleted: {
        createCompleter()
//        findRootContentItem(this)
    }
    Component.onDestruction: destroyCompleter()



    Component {
        id: completerComp
        Loader {
            id: popup
            //    property alias textItem: textItemConnections.target
            property Item textItem


            function setPosition() {
                prefixItem.text = completionModel.prefix
//                console.log(textItem.cursorRectangle)
                var _x = textItem.cursorRectangle.x
                        + textItem.cursorRectangle.width - prefixItem.contentWidth
                var _y = textItem.cursorRectangle.y
                        + textItem.cursorRectangle.height + 5
                var globalCoords = textItem.mapToItem(parent, _x, _y)
                var xMax = parent.width - popup.width
                var yMax = parent.height - popup.height
                x = Math.min(globalCoords.x, xMax)
                y = Math.min(globalCoords.y, yMax)
            }

            onWidthChanged: setPosition()
            onHeightChanged: setPosition()


            Text {
                //this is just for the calculation of text width in setPosition
                id: prefixItem
                visible: false
            }

            function insertSelection(selectedText) {
                if (state === "list")
                    popup.textItem.remove(popup.textItem.cursorPosition
                                          - completionModel.prefix.length,
                                          popup.textItem.cursorPosition)
                popup.textItem.insert(popup.textItem.cursorPosition, selectedText + "")
                completionModel.clear()
                if (completionModel.calendarKeywords.indexOf(selectedText) >= 0) state = "calendar"
            }

            Keys.forwardTo: [popup.item]
            Keys.onEscapePressed: {
                if (popup.state !== "invisible") popup.state = "invisible"
                else event.accepted = false
            }


            state: "unconnected"

            states: [
                State {
                    name: "calendar"
                    extend: "invisible"
                    when: (textItem !== null && completionModel.calendarKeywords.indexOf(completionModel.prefix) >= 0 )
                    PropertyChanges {
                        target: popup
                        sourceComponent: calendarComp
                    }
                },
                State {
                    name: "list"
                    extend: "invisible"
                    when: (textItem !== null && completionModel.count > 0)
                    PropertyChanges {
                        target: popup
                        sourceComponent: listComp
                    }
                },
                State {
                    name: "invisible"
                    when: (textItem !== null && completionModel.count === 0)
                    PropertyChanges {
                        target: popup
                        sourceComponent: keyHandler
                        visible: true
                    }
                    PropertyChanges {
                        target: textItemConnections
                        connTarget: textItem
                    }
                },
                State {
                    name: "unconnected"
                    when: textItem === null
                    PropertyChanges {
                        target: popup
                        visible: false
                    }
                }
            ]

            Connections {
                id: textItemConnections
                property alias connTarget: textItemConnections.target
                target: TextField {}
                onTextChanged: completionModel.triggered(false)
            }


            ListModel {

                id: completionModel
                property var calendarKeywords: mainController.calendarKeywords //["due:", "t:"]
                property var sourceModel: mainController.completionStrings

                property string prefix: ""

                function getPrefix() {
                    var match = textItem.text.substring(0, textItem.cursorPosition).match(/(^.*\s|^)(\S+)$/)
                    if (match) {
                        prefix =  match[2]
                    }
                    else prefix = ""
                }

                function populateModel(){
                    clear()
                    if (popup.state === "unconnected") return;
                    var filteredList = sourceModel.filter(function(completionItem) {
                        return (completionItem.substring(0, prefix.length) === prefix)
                    })
                    filteredList.forEach(function(i){
                        append({"text": i})
                    })
                }

                function triggered(manual) {
                    completionModel.getPrefix()
                    if (manual || (!manual && prefix.length > 0)) populateModel()
                    else clear()
                }
            }

            Component {
                id: keyHandler
                Item {
                    Keys.onSpacePressed: {
                        if (event.modifiers === Qt.ControlModifier) {
                            completionModel.triggered(true)
                            event.accepted = true
                        }
                        else event.accepted = false
                    }
                }
            }

            Component {
                id: calendarComp
                Calendar {
                    signal selected()
                    onSelected: {
                        insertSelection(selectedDate.toLocaleString(Qt.locale("en_US"), 'yyyy-MM-dd'))
                        popup.state = "invisible"
                    }

                    onClicked: selected()

                    Keys.onRightPressed: {
                        if (event.modifiers === Qt.ControlModifier) {
                            var d = new Date(selectedDate)
                            d.setDate(d.getDate() - 1)
                            selectedDate = new Date(d.setMonth(d.getMonth() + 1))
                            event.accepted
                        }
                    }
                    Keys.onLeftPressed: {
                        if (event.modifiers === Qt.ControlModifier) {
                            var d = new Date(selectedDate)
                            d.setDate(d.getDate() + 1)
                            selectedDate = new Date(d.setMonth(d.getMonth() - 1))
                            event.accepted
                        }
                    }
                    Keys.onDownPressed: {
                        if (event.modifiers === Qt.ControlModifier) {
                            var d = new Date(selectedDate)
                            d.setDate(d.getDate() - 7)
                            selectedDate = new Date(d.setFullYear(d.getFullYear() + 1))
                            event.accepted
                        }
                    }
                    Keys.onUpPressed: {
                        if (event.modifiers === Qt.ControlModifier) {
                            var d = new Date(selectedDate)
                            d.setDate(d.getDate() + 7)
                            selectedDate = new Date(d.setFullYear(d.getFullYear() - 1))
                            event.accepted
                        }
                    }
                    Keys.onReturnPressed: selected()
                    Keys.onEnterPressed: selected()
                }
            }

            Component {
                id: listComp
                Rectangle {
                    height: Math.min(200,list.contentHeight)
                    width: Math.min(150)//,list.implicitWidth)

                    color: "white"
                    border {
                        color: "black"
                        width: 1
                    }

                    Keys.forwardTo: [list]

                    ListView {
                        id: list

                        signal selected()
                        onSelected: insertSelection(completionModel.get(currentIndex).text)
                        anchors.fill: parent
                        leftMargin: 3
                        rightMargin: 3
//                        topMargin: 3
//                        bottomMargin: 3
                        spacing: 3
                        clip: true

                        model: completionModel
                        delegate:
                            Label {
                            id: complItemTxt
                            text: model.text
                            width: parent.width - 6

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    list.currentIndex = model.index
                                }
                                onClicked: {
                                    list.currentIndex = model.index
                                    list.selected()
                                }
                            }
                        }

                        highlight: Rectangle {
                            color: systemPalette.highlight
                            opacity: 0.5
                        }

                        keyNavigationWraps: true
                        Keys.onLeftPressed: {
                            completionModel.clear()
                            event.accepted = false
                        }
                        Keys.onRightPressed:{
                            completionModel.clear()
                            event.accepted = false
                        }
                        Keys.onReturnPressed: selected()
                        Keys.onEnterPressed: selected()
                        Keys.onTabPressed: selected()
                    }
                }
            }
        }
    }
}
