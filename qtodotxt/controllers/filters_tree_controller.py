from PyQt5 import QtCore
from PyQt5 import QtGui
from qtodotxt.lib.filters import ContextFilter, CompleteTasksFilter, DueFilter, DueOverdueFilter, DueThisMonthFilter, \
    DueThisWeekFilter, DueTodayFilter, DueTomorrowFilter, HasContextsFilter, HasDueDateFilter, HasProjectsFilter, \
    ProjectFilter, UncategorizedTasksFilter, AllTasksFilter, PriorityFilter, HasPriorityFilter


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
        if icon:
            self.setIcon(icon)


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

    def addFilter(self, flt, count):
        parent = self._filterItemByFilterType[type(flt)]
        item = FilterItem(parent, "{} ({})".format(flt.text, count), flt)

    def clear(self):
        QtGui.QStandardItemModel.clear(self)
        self._addDefaultTreeItems()
        self._initFilterTypeMappings()

    def _addDefaultTreeItems(self):
        self._allTasksItem = FilterItem(self, 'All',
                                                  AllTasksFilter(),
                                                  QtGui.QIcon(self.style + '/resources/FilterAll.png'))
        self._uncategorizedTasksItem = FilterItem(
            self, 'Uncategorized',
            UncategorizedTasksFilter(), QtGui.QIcon(self.style + '/resources/FilterUncategorized.png'))
        self._dueItem = FilterItem(self, 'Due', HasDueDateFilter(), QtGui.QIcon(self.style + '/resources/FilterDue.png'))
        self._contextsItem = FilterItem(self, 'Contexts',
                                                  HasContextsFilter(),
                                                  QtGui.QIcon(self.style + '/resources/FilterContexts.png'))
        self._projectsItem = FilterItem(self, 'Projects',
                                                  HasProjectsFilter(),
                                                  QtGui.QIcon(self.style + '/resources/FilterProjects.png'))
        self._priorityItem = FilterItem(self, 'Priorities',
                                                  HasPriorityFilter(),
                                                  QtGui.QIcon(self.style + '/resources/FilterComplete.png'))
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
        FilterItem(parentItem, "{} ({})".format(flt.text, number), flt=flt, icon=icon, order=sortKey)
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

        self._completeTasksItem.setText("Complete (%d)" % nbComplete)
        if (show_completed is True):
            self._allTasksItem.setText("All ({0}; {1})".format(nbPending, nbComplete))
            self._dueItem.setText("Due ({0}; {1})".format(nbDue, nbDueCompl))
            self._contextsItem.setText("Contexts ({0}; {1})".format(nbContexts, nbContCompl))
            self._projectsItem.setText("Projects ({0}; {1})".format(nbProjects, nbProjCompl))
            self._priorityItem.setText("Priority ({0}; {1})".format(nbPriority, nbPrioCompl))
            self._uncategorizedTasksItem.setText("Uncategorized ({0}; {1})".format(nbUncategorized, nbUncatCompl))
        else:
            self._allTasksItem.setText("All (%d)" % nbPending)
            self._contextsItem.setText("Contexts (%d)" % nbContexts)
            self._projectsItem.setText("Projects (%d)" % nbProjects)
            self._dueItem.setText("Due (%d)" % nbDue)
            self._priorityItem.setText("Priority (%d)" % nbPriority)
            self._uncategorizedTasksItem.setText("Uncategorized (%d)" % nbUncategorized)



class FiltersTreeController(QtCore.QObject):

    filterSelectionChanged = QtCore.pyqtSignal(list)

    def __init__(self):
        QtCore.QObject.__init__(self)
        self._is_showing_filters = False
        self.model = FiltersModel(self)

    def view_filterSelectionChanged(self, filters):
        if not self._is_showing_filters:
            self.filterSelectionChanged.emit(filters)

    def showFilters(self, mfile, show_completed=False):
        self._is_showing_filters = True
        #previouslySelectedFilters = self.view.getSelectedFilters()
        self.model.clear()
        self._addAllContexts(mfile, show_completed)
        self._addAllProjects(mfile, show_completed)
        self._addAllDueRanges(mfile, show_completed)
        self._addAllPriorities(mfile, show_completed)
        self._updateCounter(mfile, show_completed)
        self._is_showing_filters = False
        #self._reselect(previouslySelectedFilters)

    def _updateCounter(self, mfile, show_completed=False):
        rootCounters = mfile.getTasksCounters()
        self.model.updateTopLevelTitles(rootCounters, show_completed)

    def _addAllContexts(self, mfile, show_completed):
        contexts = mfile.getAllContexts(show_completed)
        for context, number in contexts.items():
            filter = ContextFilter(context)
            self.model.addFilter(filter, number)

    def _addAllProjects(self, mfile, show_completed):
        projects = mfile.getAllProjects(show_completed)
        for project, number in projects.items():
            filter = ProjectFilter(project)
            self.model.addFilter(filter, number)

    def _addAllPriorities(self, mfile, show_completed):
        priorities = mfile.getAllPriorities(show_completed)
        for priority, number in priorities.items():
            filter = PriorityFilter(priority)
            self.model.addFilter(filter, number)

    def _addAllDueRanges(self, mfile, show_completed):

        dueRanges, rangeSorting = mfile.getAllDueRanges(show_completed)

        for range, number in dueRanges.items():
            if range == 'Today':
                filter = DueTodayFilter(range)
                sortKey = rangeSorting['Today']
            elif range == 'Tomorrow':
                filter = DueTomorrowFilter(range)
                sortKey = rangeSorting['Tomorrow']
            elif range == 'This week':
                filter = DueThisWeekFilter(range)
                sortKey = rangeSorting['This week']
            elif range == 'This month':
                filter = DueThisMonthFilter(range)
                sortKey = rangeSorting['This month']
            elif range == 'Overdue':
                filter = DueOverdueFilter(range)
                sortKey = rangeSorting['Overdue']

            self.model.addDueRangeFilter(filter, number, sortKey)

    def _reselect(self, previouslySelectedFilters):
        for filter in previouslySelectedFilters:
            self.view.selectFilter(filter)
        if not self.view.getSelectedFilters():
            self.view.selectAllTasksFilter()
