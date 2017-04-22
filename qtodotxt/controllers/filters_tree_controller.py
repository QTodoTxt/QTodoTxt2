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
        print("ROLES", roles)
        return roles

    def addFilter(self, flt, count):
        parent = self._filterItemByFilterType[type(flt)]
        item = FilterItem(parent, flt.text, flt)
        item.setTotalCount(count)

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
    def addDueRangeFilter(self, flt, number=0, sortKey=0):
        parentItem = self._dueItem
        icon = self._filterIconByFilterType[type(flt)]
        item = FilterItem(parentItem, flt.text, flt=flt, icon=icon, order=sortKey)
        item.setTotalCount(number)

        #parentItem.setExpanded(True)
        #parentItem.sortChildren(1, QtCore.Qt.AscendingOrder)

    def updateTopLevelTitles(self, counters, show_completed=False):
        nbPending = counters['Pending']
        nbDue = counters['Due']
        nbUncategorized = counters['Uncategorized']
        nbContexts = counters['Contexts']
        nbProjects = counters['Projects']
        nbComplete = counters['Complete']
        nbContCompl = counters['ContCompl']
        nbProjCompl = counters['ProjCompl']
        nbDueCompl = counters['DueCompl']
        nbUncatCompl = counters['UncatCompl']
        nbPriority = counters['Priority']
        nbPrioCompl = counters['PrioCompl']

        self._completeTasksItem.setTotalCount(nbComplete)
        self._allTasksItem.setCounts(nbPending, nbComplete)
        self._dueItem.setCounts(nbDue, nbDueCompl)
        self._contextsItem.setCounts(nbContexts, nbContCompl)
        self._projectsItem.setCounts(nbProjects, nbProjCompl)
        self._priorityItem.setCounts(nbPriority, nbPrioCompl)
        self._uncategorizedTasksItem.setCounts(nbUncategorized, nbUncatCompl)

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



class FiltersTreeController(QtCore.QObject):

    filterSelectionChanged = QtCore.pyqtSignal(list)

    def __init__(self):
        QtCore.QObject.__init__(self)
        self.model = FiltersModel(self)

    def showFilters(self, mfile, show_completed=False):
        self.model.clear()
        self._addAllContexts(mfile, show_completed)
        self._addAllProjects(mfile, show_completed)
        self._addAllDueRanges(mfile, show_completed)
        self._addAllPriorities(mfile, show_completed)
        self._updateCounter(mfile, show_completed)

    def _updateCounter(self, mfile, show_completed=False):
        rootCounters = mfile.getTasksCounters()
        self.model.updateTopLevelTitles(rootCounters, show_completed)

    def _addAllContexts(self, mfile, show_completed):
        contexts = mfile.getAllContexts(show_completed)
        for context, number in contexts.items():
            mfilter = ContextFilter(context)
            self.model.addFilter(mfilter, number)

    def _addAllProjects(self, mfile, show_completed):
        projects = mfile.getAllProjects(show_completed)
        for project, number in projects.items():
            mfilter = ProjectFilter(project)
            self.model.addFilter(mfilter, number)

    def _addAllPriorities(self, mfile, show_completed):
        priorities = mfile.getAllPriorities(show_completed)
        for priority, number in priorities.items():
            mfilter = PriorityFilter(priority)
            self.model.addFilter(mfilter, number)

    def _addAllDueRanges(self, mfile, show_completed):

        dueRanges, rangeSorting = mfile.getAllDueRanges(show_completed)

        for mrange, number in dueRanges.items():
            if mrange == 'Today':
                mfilter = DueTodayFilter(mrange)
                sortKey = rangeSorting['Today']
            elif mrange == 'Tomorrow':
                mfilter = DueTomorrowFilter(mrange)
                sortKey = rangeSorting['Tomorrow']
            elif mrange == 'This week':
                mfilter = DueThisWeekFilter(mrange)
                sortKey = rangeSorting['This week']
            elif mrange == 'This month':
                mfilter = DueThisMonthFilter(mrange)
                sortKey = rangeSorting['This month']
            elif mrange == 'Overdue':
                mfilter = DueOverdueFilter(mrange)
                sortKey = rangeSorting['Overdue']

            self.model.addDueRangeFilter(mfilter, number, sortKey)
