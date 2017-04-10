import logging
import os
import sys
import time

from PyQt5 import QtCore, QtGui
from PyQt5 import QtWidgets

from qtodotxt.lib import tasklib
from qtodotxt.lib.file import ErrorLoadingFile, File, FileObserver

from qtodotxt.controllers.filters_tree_controller import FiltersTreeController
from qtodotxt.lib.filters import SimpleTextFilter, FutureFilter, IncompleteTasksFilter, CompleteTasksFilter


logger = logging.getLogger(__name__)

FILENAME_FILTERS = ';;'.join([
    'Text Files (*.txt)',
    'All Files (*.*)'])


class MainController(QtCore.QObject):

    _show_toolbar = QtCore.pyqtSignal(int)
    error = QtCore.pyqtSignal(str)

    def __init__(self, args):
        super(MainController, self).__init__()
        self._args = args
        self._tasksList = []
        # use object variable for setting only used in this class
        # others are accessed through QSettings
        self._settings = QtCore.QSettings()
        self._showCompleted = True
        self._showFuture = True
        self._file = File()
        self._fileObserver = FileObserver(self, self._file)
        self.modified = False
        self._initFiltersTree()

    def setup(self, view):
        self.view = view

        #self._initControllers() # not necessary anymore
        self._fileObserver.fileChangetSig.connect(self.openFileByName)
        #self.view.closeEventSignal.connect(self.view_onCloseEvent)
        filters = self._settings.value("current_filters", ["All"])
        #self._filters_tree_controller.view.setSelectedFiltersByNames(filters)
        #self._menu_controller.updateRecentFileActions()

    def showError(self, msg):
        self.error.emit(msg)
    
    @QtCore.pyqtSlot('QVariant')
    def filterRequest(self, idx):
        item = self._filters_tree_controller.model.itemFromIndex(idx)
        self._applyFilters(filters=[item.filter])

    taskListChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('QVariant', notify=taskListChanged)
    def taskList(self):
        return self._tasksList
    
    # not dure we should enable that
    #@taskList.setter
    #def taskList(self, taskList):
        #self._tasksListQml = taskList
        #self.taskListChanged.emit()

    actionsChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('QVariant', notify=actionsChanged)
    def actions(self):
        return self._actions

    showFutureChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('bool', notify=showFutureChanged)
    def showFuture(self):
        return self._showFuture

    @showFuture.setter
    def showFuture(self, val):
        self._showFuture = val
        self._showFutureChanged.emit(val)

    searchTextChanged = QtCore.pyqtSignal(str)

    @QtCore.pyqtProperty('QString', notify=searchTextChanged)
    def searchText(self):
        return self._searchText

    @searchText.setter
    def searchText(self, txt):
        self._searchText = txt
        self.searchTextChanged.emit(txt)

    showCompletedChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('bool', notify=showCompletedChanged)
    def showCompleted(self):
        return self._showCompleted

    @showCompleted.setter
    def showCompleted(self, val):
        self._showCompleted = val
        self.showCompleted.emit(val)

    def auto_save(self):
        if int(self._settings.value("auto_save", 1)):
            self.save()

    def _initControllers(self):
        self._initFiltersTree()
        self._initTasksList()
        self._initContextualMenu()
        self._initActions()
        self._initMenuBar()
        self._initToolBar()
        self._initSearchText()

    def _initMenuBar(self):
        menu = self.view.menuBar()
        self._menu_controller = MenuController(self, menu)

    def exit(self):
        self.view.close()
        sys.exit()

    def start(self):
        print("SHOW")
        self._updateTitle()

        if self._args.file:
            filename = self._args.file
        else:
            filename = self._settings.value("last_open_file")

        if filename:
            try:
                self.openFileByName(filename)
            except ErrorLoadingFile as ex:
                self.showError(str(ex))

        if self._args.quickadd:
            self._tasks_list_controller.createTask()
            self.save()
            self.exit()

        self._tasksList = self._file.tasks
        self.taskListChanged.emit()

    def _initFiltersTree(self):
        self._filters_tree_controller = FiltersTreeController()
        self.filtersChanged.emit()
        self._filters_tree_controller.filterSelectionChanged.connect(self._onFilterSelectionChanged)
        #self.view.filterSelectionChanged.connect(self.view_filterSelectionChanged)

    def _onFilterSelectionChanged(self, filters):
        self._applyFilters(filters=filters)

    filtersChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('QVariant', notify=filtersChanged)
    def filtersModel(self):
        return self._filters_tree_controller.model

    def _applyFilters(self, filters=None, searchText=None):
        # First we filter with filters tree
        if filters is None:
            filters = self._filters_tree_controller.view.getSelectedFilters()
        tasks = tasklib.filterTasks(filters, self._file.tasks)
        # Then with our search text
        if searchText:
            tasks = tasklib.filterTasks([SimpleTextFilter(searchText)], tasks)
        # with future filter if needed
        if not self._showFuture:
            tasks = tasklib.filterTasks([FutureFilter()], tasks)
        # with complete filter if needed
        if not CompleteTasksFilter() in filters and not self._showCompleted:
            tasks = tasklib.filterTasks([IncompleteTasksFilter()], tasks)
        self._tasksList = tasks
        self.taskListChanged.emit()

    def _initSearchText(self):
        self.view.tasks_view.tasks_search_view.searchTextChanged.connect(
            self._onSearchTextChanged)

    def _onSearchTextChanged(self, searchText):
        self._applyFilters(searchText=searchText)

    def _initContextualMenu(self):

        # Context menu
        # controller.view.setContextMenuPolicy(QtCore.Qt.ActionsContextMenu)
        self._tasks_list_controller.view.setContextMenuPolicy(QtCore.Qt.CustomContextMenu)
        self._tasks_list_controller.view.customContextMenuRequested.connect(self.showContextMenu)
        self._contextMenu = QtWidgets.QMenu(self.view)
        self._contextMenu.addAction(self._tasks_list_controller.createTaskAction)
        self._contextMenu.addAction(self._tasks_list_controller.createTaskActionOnTemplate)
        self._contextMenu.addAction(self._tasks_list_controller.editTaskAction)
        self._contextMenu.addAction(self._tasks_list_controller.copySelectedTasksAction)
        self._contextMenu.addAction(self._tasks_list_controller.addLinkAction)
        self._contextMenu.addSeparator()
        self._contextMenu.addAction(self._tasks_list_controller.completeSelectedTasksAction)
        if int(self._settings.value("show_delete", 1)):
            self._contextMenu.addAction(self._tasks_list_controller.deleteSelectedTasksAction)
        self._contextMenu.addSeparator()
        self._contextMenu.addAction(self._tasks_list_controller.increasePrioritySelectedTasksAction)
        self._contextMenu.addAction(self._tasks_list_controller.decreasePrioritySelectedTasksAction)

    def showContextMenu(self, position):
        tasks = self._tasks_list_controller.view.getSelectedTasks()
        if tasks:
            self._contextMenu.exec_(self._tasks_list_controller.view.mapToGlobal(position))

    def _tasks_list_taskDeleted(self, task):
        self._file.tasks.remove(task)
        self._onFileUpdated()

    def _tasks_list_taskCreated(self, task):
        self._file.tasks.append(task)
        self._onFileUpdated()

    def _tasks_list_taskModified(self):
        self._onFileUpdated()

    def _tasks_list_taskArchived(self, task):
        self._file.saveDoneTask(task)
        self._file.tasks.remove(task)
        self._onFileUpdated()

    def _archive_all_done_tasks(self):
        done = [task for task in self._file.tasks if task.is_complete]
        for task in done:
            self._file.saveDoneTask(task)
            self._file.tasks.remove(task)
        self._onFileUpdated()

    def _onFileUpdated(self):
        self._filters_tree_controller.showFilters(self._file, self._showCompleted)
        self.modified = True
        self.auto_save()

    def canExit(self):
        if not self._modified:
            return True
        button = self._dialogs.showSaveDiscardCancel(self.tr('Unsaved changes...'))
        if button == QtWidgets.QMessageBox.Save:
            self.save()
            return True
        else:
            return button == QtWidgets.QMessageBox.Discard

    modifiedChanged = QtCore.pyqtSignal(bool)

    @QtCore.pyqtProperty('bool', notify=modifiedChanged)
    def modified(self):
        self._modified

    @modified.setter
    def modified(self, val):
        self._modified = val
        self._updateTitle()

    def save(self):
        logger.debug('MainController.save called.')
        self._fileObserver.clear()
        filename = self._file.filename
        ok = True
        if not filename:
            (filename, ok) = \
                QtWidgets.QFileDialog.getSaveFileName(self.view, filter=FILENAME_FILTERS)
        if ok and filename:
            self._file.save(filename)
            self._settings.setValue("last_open_file", filename)
            self._settings.sync()
            self._modfied = True
            logger.debug('Adding {} to watchlist'.format(filename))
            self._fileObserver.addPath(self._file.filename)

    def _updateTitle(self):
        title = 'QTodoTxt - '
        if self._file.filename:
            filename = os.path.basename(self._file.filename)
            title += filename
        else:
            title += 'Untitled'
        if self._modified:
            title += ' (*)'
        # FIXME: set title as a property read from QML

    def open(self):
        (filename, ok) = \
            QtWidgets.QFileDialog.getOpenFileName(self.view, filter=FILENAME_FILTERS)

        if ok and filename:
            try:
                self.openFileByName(filename)
            except ErrorLoadingFile as ex:
                self.showError(str(ex))

    def new(self):
        if self.canExit():
            self._file = File()
            self._loadFileToUI()

    def revert(self):
        if self._dialogs.showConfirm(self.tr('Revert to saved file (and lose unsaved changes)?')):
            try:
                self.openFileByName(self._file.filename)
            except ErrorLoadingFile as ex:
                self.showError(str(ex))

    def openFileByName(self, filename):
        logger.debug('MainController.openFileByName called with filename="{}"'.format(filename))
        self._fileObserver.clear()
        try:
            self._file.load(filename)
        except Exception as ex:
            currentfile = self._settings.value("last_open_file", "")
            if currentfile == filename:
                self.showError(self.tr("Current file '{}' is not available.\nException: {}").format(filename, ex))
            else:
                self.showError(self.tr("Error opening file: {}.\n Exception:{}").format(filename, ex))
            return
        self._loadFileToUI()
        self._settings.setValue("last_open_file", filename)
        self._settings.sync()
        logger.debug('Adding {} to watchlist'.format(filename))
        self._fileObserver.addPath(self._file.filename)
        #self.updateRecentFile()

    def updateRecentFile(self):
        lastOpenedArray = self._menu_controller.getRecentFileNames()
        if self._file.filename in lastOpenedArray:
            lastOpenedArray.remove(self._file.filename)
        lastOpenedArray = lastOpenedArray[:self._menu_controller.maxRecentFiles]
        lastOpenedArray.insert(0, self._file.filename)
        self._settings.setValue("lastOpened", lastOpenedArray[: self._menu_controller.maxRecentFiles])
        self._menu_controller.updateRecentFileActions()

    def _loadFileToUI(self):
        self._modified = False
        self._filters_tree_controller.showFilters(self._file, self._showCompleted)

    def updateFilters(self):
        self._onFilterSelectionChanged(self._filters_tree_controller.view.getSelectedFilters())
