import QtQuick 2.7
import QtQuick.Dialogs 1.1

MessageDialog {
//        id: aboutBox
        property string appName: "QTodoTxt"
        title: "About " + appName
        text: 'QTodoTxt is a cross-platform UI client for todo.txt files (see http://todotxt.com)

Copyright © David Elentok 2011
Copyright © Matthieu Nantern 2013-2015
Copyright © QTT Development Team 2015-2016'
        icon: StandardIcon.Information
}
