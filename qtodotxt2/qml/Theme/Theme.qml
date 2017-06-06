pragma Singleton
import QtQuick  2.5

QtObject {
    property SystemPalette activePalette: SystemPalette {
        colorGroup: SystemPalette.Active
    }

    property real minRowHeight: 30

    property int mediumSpace: 10
    property int smallSpace: 5
    property int tinySpace: 2

    property string name: "white" // = "dark" or "white"
    property string pathPrefix: "qrc:///" + name + "_icons/resources/" + name + "/" //this will later be sth like qrc:///.../Theme/

    property var mapNameSource: {
        "document-new": "",
        "document-open": "",
        "document-save": "FileSave.png",
        "list-add": "TaskCreate.png",
        "list-remove": "TaskDelete.png",
        "document-edit": "TaskEdit.png",
        "checkmark": "TaskComplete.png",
        "arrow-up": "TaskPriorityIncrease.png",
        "arrow-down": "TaskPriorityDecrease.png",
        "search": "ActionSearch.png",
        "view-filter": "sidepane.png",
        "show-completed": "show_completed.png", //FIXME search default icon-name
        "future": "future.png", //FIXME search default icon-name
        "archive": "archive.png", //FIXME search default icon-name
        "addLink": "link.png", //FIXME search default icon-name
        "help-about": "", //FIXME search default icon-name
        'qtodotxt-filter-all': 'FilterAll.png',
        'qtodotxt-filter-uncategorized': 'FilterUncategorized.png',
        'qtodotxt-filter-due': 'FilterDue.png',
        'qtodotxt-filter-contexts': 'FilterContexts.png',
        'qtodotxt-filter-projects': 'FilterProjects.png',
        'qtodotxt-filter-complete': 'FilterComplete.png',
        'qtodotxt-filter-due-today': 'FilterDueToday.png',
        'qtodotxt-filter-due-tomorrow': 'FilterDueTomorrow.png',
        'qtodotxt-filter-due-week': 'FilterDueWeek.png',
        'qtodotxt-filter-due-month': 'FilterDueMonth.png',
        'qtodotxt-filter-due-overdue': 'FilterDueOverdue.png'
    }

    // resolve icon source path from icon name
    function iconSource(iconName) {
        if (mapNameSource[iconName])
            return pathPrefix + mapNameSource[iconName]
        else return ""
    }
}
