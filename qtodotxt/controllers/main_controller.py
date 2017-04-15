import logging
import os
import string

from PyQt5 import QtCore

from qtodotxt.lib import tasklib
from qtodotxt.lib.file import ErrorLoadingFile, File, FileObserver

from qtodotxt.controllers.filters_tree_controller import FiltersTreeController
from qtodotxt.lib.filters import SimpleTextFilter, FutureFilter, IncompleteTasksFilter, CompleteTasksFilter

logger = logging.getLogger(__name__)

FILENAME_FILTERS = ';;'.join(['Text Files (*.txt)', 'All Files (*.*)'])


class MainController(QtCore.QObject):

    error = QtCore.pyqtSignal(str, arguments=["msg"])

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
        self._modified = False
        self._initFiltersTree()
        self._title = "QTodoTxt"
        self._recentFiles = self._settings.value("recent_files", [])
        self._searchText = ""
        self._fileObserver.fileChangetSig.connect(self.open)
        # filters = self._settings.value("current_filters", ["All"])  # move to QML
        self._updateCompletionStrings()

    def _taskModified(self, task):
        self.setModified(True)

    def showError(self, msg):
        print("ERROR", msg)
        self.error.emit(msg)

    completionChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty('QStringList', notify=completionChanged)
    def completionStrings(self):
        return self._completionStrings
    
    def _updateCompletionStrings(self):
        contexts = ['@' + name for name in self._file.getAllContexts(True)]
        projects = ['+' + name for name in self._file.getAllProjects(True)]
        lowest_priority = self._settings.value("lowest_priority", "D")
        idx = string.ascii_uppercase.index(lowest_priority) + 1
        priorities = ['(' + val +')' for val in string.ascii_uppercase[:idx]]
        self._completionStrings = contexts + projects + priorities
        self.completionChanged.emit()

    @QtCore.pyqtSlot('QVariant')
    def filterRequest(self, idx):
        item = self._filters_tree_controller.model.itemFromIndex(idx)
        self._applyFilters(filters=[item.filter])

    @QtCore.pyqtSlot('QString', 'int', result='int')
    def newTask(self, text='', after=None):
        task = tasklib.Task(text)
        task.modified.connect(self._taskModified)
        if after is None:
            after = len(self._tasksList) - 1
        self._file.tasks.append(task)
        self._tasksList.insert(after + 1, task)  # force the new task to be visible
        self.setModified(True)
        self.taskListChanged.emit()
        return after + 1

    @QtCore.pyqtSlot('QVariant')
    def deleteTask(self, task):
        if not isinstance(task, tasklib.Task):
            # if task is not a task assume it is an int
            task = self._file.tasks[task]
        self._file.tasks.remove(task)
        self.setModified(True)
        self._applyFilters()  # update filtered list for UI

    taskListChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('QVariant', notify=taskListChanged)
    def taskList(self):
        return self._tasksList

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
        self._applyFilters()
        self.searchTextChanged.emit(txt)

    showCompletedChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('bool', notify=showCompletedChanged)
    def showCompleted(self):
        return self._showCompleted

    @showCompleted.setter
    def showCompleted(self, val):
        self._showCompleted = val
        self.showCompletedChanged.emit(val)

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

    def start(self):
        if self._args.file:
            filename = self._args.file
        else:
            filename = self._settings.value("last_open_file")

        if filename:
            try:
                self.open(filename)
            except ErrorLoadingFile as ex:
                self.showError(str(ex))

        if self._args.quickadd:
            self._tasks_list_controller.createTask()
            self.save()
            self.exit()

        self._tasksList = self._file.tasks[:]
        self.taskListChanged.emit()
        self._updateTitle()

    def _initFiltersTree(self):
        self._filters_tree_controller = FiltersTreeController()
        self.filtersChanged.emit()
        self._filters_tree_controller.filterSelectionChanged.connect(self._onFilterSelectionChanged)

    def _onFilterSelectionChanged(self, filters):
        self._applyFilters(filters=filters)

    filtersChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('QVariant', notify=filtersChanged)
    def filtersModel(self):
        return self._filters_tree_controller.model

    def _applyFilters(self, filters=None):
        # First we filter with filters tree
        #if filters is None:
        #filters = self._filters_tree_controller.view.getSelectedFilters()
        tasks = tasklib.filterTasks(filters, self._file.tasks)
        # Then with our search text
        if self._searchText:
            tasks = tasklib.filterTasks([SimpleTextFilter(self._searchText)], tasks)
        # with future filter if needed
        if not self._showFuture:
            tasks = tasklib.filterTasks([FutureFilter()], tasks)
        # with complete filter if needed
        if not self._showCompleted and (not filters or not CompleteTasksFilter() in filters):
            tasks = tasklib.filterTasks([IncompleteTasksFilter()], tasks)
        self._tasksList = tasks
        self.taskListChanged.emit()

    def _archive_all_done_tasks(self):
        done = [task for task in self._file.tasks if task.is_complete]
        for task in done:
            self._file.saveDoneTask(task)
            self._file.tasks.remove(task)
        self._onFileUpdated()

    def _onFileUpdated(self):
        self._filters_tree_controller.showFilters(self._file, self._showCompleted)
        self.setModified(True)
        self.auto_save()

    modifiedChanged = QtCore.pyqtSignal(bool)

    @QtCore.pyqtProperty('bool', notify=modifiedChanged)
    def modified(self):
        return self._modified

    def setModified(self, val):
        self._modified = val
        self._updateTitle()
        self._updateCompletionStrings()
        self.modifiedChanged.emit(val)

    def save(self):
        logger.debug('MainController.save called.')
        self._fileObserver.clear()
        filename = self._file.filename
        self._file.save(filename)
        self._settings.setValue("last_open_file", filename)
        self._settings.sync()
        self.setModified(False)
        logger.debug('Adding %s to watchlist', filename)
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
        self._title = title
        self.titleChanged.emit(self._title)

    titleChanged = QtCore.pyqtSignal(str)

    @QtCore.pyqtProperty('QString', notify=titleChanged)
    def title(self):
        return self._title

    @QtCore.pyqtSlot(result='bool')
    def canExit(self):
        self.auto_save()
        return self._modified

    def new(self):
        if self.canExit():
            self._file = File()
            self._loadFileToUI()

    @QtCore.pyqtSlot('QString')
    def open(self, filename):
        if filename.startswith("file:/"):
            filename = filename[6:] 
        logger.debug('MainController.open called with filename="%s"', filename)
        self._fileObserver.clear()
        try:
            self._file.load(filename)
        except Exception as ex:
            self.showError(self.tr("Error opening file: {}.\n Exception:{}").format(filename, ex))
            return
        self._loadFileToUI()
        self._settings.setValue("last_open_file", filename)
        self._fileObserver.addPath(self._file.filename)
        for task in self._file.tasks:
            task.modified.connect(self._taskModified)
        self._applyFilters()
        self.taskListChanged.emit()
        self.updateRecentFile()

    recentFilesChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('QVariant', notify=recentFilesChanged)
    def recentFiles(self):
        return self._recentFiles

    def updateRecentFile(self):
        if self._file.filename in self._recentFiles:
            self._recentFiles.remove(self._file.filename)
        self._recentFiles.insert(0, self._file.filename)
        self._recentFiles = self._recentFiles[:int(self._settings.value("max_recent_files", 6))]
        self._settings.setValue("recent_files", self._recentFiles)
        self.recentFilesChanged.emit()

    def _loadFileToUI(self):
        self.setModified(False)
        self._filters_tree_controller.showFilters(self._file, self._showCompleted)
