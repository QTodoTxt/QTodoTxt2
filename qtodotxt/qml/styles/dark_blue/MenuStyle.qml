import QtQuick 2.5
import QtQuick.Controls.Styles 1.4

MenuStyle {
    frame: Component { Rectangle {
            anchors.fill: parent
            color: "#eff0f1"
            border{
                color: "#76797C"
                width: 2
            }
        }}
    //    itemDelegate.background: Rectangle {
    //        color: (styleData.selected ? "#eff0f1" : "#eff0f1")
    //    }
}
