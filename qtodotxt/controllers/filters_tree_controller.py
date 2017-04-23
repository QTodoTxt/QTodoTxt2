from PyQt5 import QtCore
from PyQt5 import QtGui
from qtodotxt.lib.filters import ContextFilter, CompleteTasksFilter, DueFilter, DueOverdueFilter, DueThisMonthFilter, \
    DueThisWeekFilter, DueTodayFilter, DueTomorrowFilter, HasContextsFilter, HasDueDateFilter, HasProjectsFilter, \
    ProjectFilter, UncategorizedTasksFilter, AllTasksFilter, PriorityFilter, HasPriorityFilter


TotalCountRole = QtCore.Qt.UserRole + 1
CompletedCountRole = QtCore.Qt.UserRole + 2


class FilterItem(QtGui.QStandardItem):
    def __init__(self, parent, strings, flt=None, icon=None, order=None):
        QtGui.QStandardItem.__init__(self, strings)
        self.setSelectable(True)
        self.setEnabled(True)
        self.setData(flt, QtCore.Qt.UserRole)
        self.filter = flt
        parent.appendRow([self])
        #if order:
        #self.setText(1, str(order))
        self.iconSource = 'FilterAll.png'
        if icon:
            self.setIcon(icon)

    def setCounts(self, total, completed):
        self.setTotalCount(total)
        self.setCompletedCount(completed)

    def setTotalCount(self, total):
        self.setData(total, TotalCountRole)

    def setCompletedCount(self, val):
        self.setData(val, CompletedCountRole)


class FiltersModel(QtGui.QStandardItemModel):
    def __init__(self, parent):
        QtGui.QStandardItemModel.__init__(self, parent)
        self.style = ":/white_icons"
        if str(QtCore.QSettings().value("color_schem", "")).find("dark") >= 0:
            self.style = ":/dark_icons"
        self._filterItemByFilterType = dict()
        self._filterIconByFilterType = dict()
        self._treeItemByFilterType = dict()
        self._addDefaultTreeItems()
        self._initFilterTypeMappings()

    def roleNames(self):
        roles = QtGui.QStandardItemModel.roleNames(self)
        roles[TotalCountRole] =  b"totalCount"
        roles[CompletedCountRole] =  b"completedCount"
        return roles

    def addFilter(self, flt, counts):
        parent = self._filterItemByFilterType[type(flt)]
        item = FilterItem(parent, flt.text, flt)
        item.setCounts(*counts)

    def clear(self):
        QtGui.QStandardItemModel.clear(self)
        self._addDefaultTreeItems()
        self._initFilterTypeMappings()

    def _addDefaultTreeItems(self):
        self._allTasksItem = FilterItem(self, 'All',
                                        AllTasksFilter(), QtGui.QIcon(self.style + '/resources/FilterAll.png'))
        self._uncategorizedTasksItem = FilterItem(self, 'Uncategorized',
                                                  UncategorizedTasksFilter(),
                                                  QtGui.QIcon(self.style + '/resources/FilterUncategorized.png'))
        self._dueItem = FilterItem(self, 'Due', HasDueDateFilter(),
                                   QtGui.QIcon(self.style + '/resources/FilterDue.png'))
        self._contextsItem = FilterItem(self, 'Contexts',
                                        HasContextsFilter(), QtGui.QIcon(self.style + '/resources/FilterContexts.png'))
        self._projectsItem = FilterItem(self, 'Projects',
                                        HasProjectsFilter(), QtGui.QIcon(self.style + '/resources/FilterProjects.png'))
        self._priorityItem = FilterItem(self, 'Priorities',
                                        HasPriorityFilter(), QtGui.QIcon(self.style + '/resources/FilterComplete.png'))
        self._completeTasksItem = FilterItem(self, 'Complete',
                                             CompleteTasksFilter(),
                                             QtGui.QIcon(self.style + '/resources/FilterComplete.png'))

    def _initFilterTypeMappings(self):
        self._filterItemByFilterType[ContextFilter] = self._contextsItem
        self._filterItemByFilterType[ProjectFilter] = self._projectsItem
        self._filterItemByFilterType[DueFilter] = self._dueItem
        self._filterItemByFilterType[PriorityFilter] = self._priorityItem

        self._filterIconByFilterType[ContextFilter] = QtGui.QIcon(self.style + '/resources/FilterContexts.png')
        self._filterIconByFilterType[ProjectFilter] = QtGui.QIcon(self.style + '/resources/FilterProjects.png')

        self._filterIconByFilterType[DueTodayFilter] = QtGui.QIcon(self.style + '/resources/FilterDueToday.png')
        self._filterIconByFilterType[DueTomorrowFilter] = QtGui.QIcon(self.style + '/resources/FilterDueTomorrow.png')
        self._filterIconByFilterType[DueThisWeekFilter] = QtGui.QIcon(self.style + '/resources/FilterDueWeek.png')
        self._filterIconByFilterType[DueThisMonthFilter] = QtGui.QIcon(self.style + '/resources/FilterDueMonth.png')
        self._filterIconByFilterType[DueOverdueFilter] = QtGui.QIcon(self.style + '/resources/FilterDueOverdue.png')
        self._filterIconByFilterType[PriorityFilter] = QtGui.QIcon(self.style + '/resources/FilterComplete.png')

        self._treeItemByFilterType[AllTasksFilter] = self._allTasksItem
        self._treeItemByFilterType[UncategorizedTasksFilter] = self._uncategorizedTasksItem
        self._treeItemByFilterType[CompleteTasksFilter] = self._completeTasksItem
        self._treeItemByFilterType[HasProjectsFilter] = self._projectsItem
        self._treeItemByFilterType[HasDueDateFilter] = self._dueItem
        self._treeItemByFilterType[HasContextsFilter] = self._contextsItem
        self._treeItemByFilterType[HasPriorityFilter] = self._priorityItem

    # Predefined sorting for due ranges
    def addDueRangeFilter(self, flt, counts, sortKey=0):
        parentItem = self._dueItem
        icon = self._filterIconByFilterType[type(flt)]
        item = FilterItem(parentItem, flt.text, flt=flt, icon=icon, order=sortKey)
        item.setCounts(*counts)

        #parentItem.setExpanded(True)
        #parentItem.sortChildren(1, QtCore.Qt.AscendingOrder)

    @QtCore.pyqtSlot(result='QVariantList')
    def getRootChildren(self):
        indexes = []
        parent = self.invisibleRootItem()
        for i in range(0, parent.rowCount()):
            child = parent.child(i)
            indexes.append(child.index())
        return indexes

    @QtCore.pyqtSlot('QModelIndex', result='QString')
    def iconFromIndex(self, index):
        source = ""
        item = super(FiltersModel, self).itemFromIndex(index)
        if item is not None:
            source = item.iconSource
        return source

    @QtCore.pyqtSlot('int', result='QString')
    def iconFromRow(self, row):
        print(row)
        path = ""
        if row > 0 and row < self.rowCount():
            path = self.item(row,0).iconSource
        return path

    def updateCounters(self, counters):
        self._completeTasksItem.setTotalCount(counters['All'][1])
        self._allTasksItem.setCounts(*counters['All'])
        self._dueItem.setCounts(*counters['Due'])
        self._contextsItem.setCounts(*counters['Contexts'])
        self._projectsItem.setCounts(*counters['Projects'])
        self._priorityItem.setCounts(*counters['Priority'])
        self._uncategorizedTasksItem.setCounts(*counters['Uncategorized'])




class FiltersTreeController(QtCore.QObject):

    filterSelectionChanged = QtCore.pyqtSignal(list)

    def __init__(self):
        QtCore.QObject.__init__(self)
        self.model = FiltersModel(self)

    def showFilters(self, mfile):
        self.model.clear()
        self._addAllContexts(mfile)
        self._addAllProjects(mfile)
        self._addAllDueRanges(mfile)
        self._addAllPriorities(mfile)
        self._updateCounter(mfile)

    def _updateCounter(self, mfile):
        counters = mfile.getTasksCounters()
        self.model.updateCounters(counters)

    def _addAllContexts(self, mfile):
        contexts = mfile.getAllContexts()
        for context, number in contexts.items():
            mfilter = ContextFilter(context)
            self.model.addFilter(mfilter, number)

    def _addAllProjects(self, mfile):
        projects = mfile.getAllProjects()
        for project, counts in projects.items():
            mfilter = ProjectFilter(project)
            self.model.addFilter(mfilter, counts)

    def _addAllPriorities(self, mfile):
        priorities = mfile.getAllPriorities()
        for priority, number in priorities.items():
            mfilter = PriorityFilter(priority)
            self.model.addFilter(mfilter, number)

    def _addAllDueRanges(self, mfile):
        dueRanges = mfile.getAllDueRanges()

        # This determines the sorting of the ranges in the tree view. Lowest value first.
        rangeSorting = {'Today': 20,
                        'Tomorrow': 30,
                        'This week': 40,
                        'This month': 50,
                        'Overdue': 10}

        for flt, counts in dueRanges.items():
            self.model.addDueRangeFilter(flt, counts)
