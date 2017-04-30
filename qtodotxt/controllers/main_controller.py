import logging
import os
import string

from PyQt5 import QtCore

from qtodotxt.lib import tasklib
from qtodotxt.lib.file import File

from qtodotxt.controllers.filters_tree_controller import FiltersTreeController
from qtodotxt.lib.filters import SimpleTextFilter, FutureFilter, IncompleteTasksFilter, CompleteTasksFilter

logger = logging.getLogger(__name__)


class MainController(QtCore.QObject):

    error = QtCore.pyqtSignal(str, arguments=["msg"])
    fileExternallyModified = QtCore.pyqtSignal()

    def __init__(self, args):
        super(MainController, self).__init__()
        self._args = args
        self._filteredTasks = []
        # use object variable for setting only used in this class
        # others are accessed through QSettings
        self._settings = QtCore.QSettings()
        self._showCompleted = self._settings.value("show_completed", False)
        self._showFuture = self._settings.value("show_completed", True)
        self._file = File()
        self._file.fileModified.connect(self.fileExternallyModified)
        self._modified = False
        self._filters_tree_controller = FiltersTreeController()
        self._title = "QTodoTxt"
        self._recentFiles = self._settings.value("recent_files", [])
        self._searchText = ""
        self._currentFilters = []
        # self._currentFilters = self._settings.value("current_filters", ["All"])  # move to QML
        self._updateCompletionStrings()

    def _taskModified(self, task):
        self.setModified()
        self.auto_save()
        if not task.text:
            self.deleteTask(task)
            return
        self.applyFilters()

    def showError(self, msg):
        logger.debug("ERROR: %s", msg)
        self.error.emit(msg)

    completionChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('QStringList', notify=completionChanged)
    def completionStrings(self):
        return self._completionStrings
    
    def _updateCompletionStrings(self):
        contexts = ['@' + name for name in self._file.getAllContexts()]
        projects = ['+' + name for name in self._file.getAllProjects()]
        lowest_priority = self._settings.value("lowest_priority", "D")
        idx = string.ascii_uppercase.index(lowest_priority) + 1
        priorities = ['(' + val +')' for val in string.ascii_uppercase[:idx]]
        self._completionStrings = contexts + projects + priorities + ['due:']
        self.completionChanged.emit()

    @QtCore.pyqtSlot('QModelIndexList')
    def filterByIndexes(self, idxs):
        filters = [self._filters_tree_controller.model.itemFromIndex(idx).filter for idx in idxs]
        self._currentFilters = filters
        self.applyFilters()

    @QtCore.pyqtSlot('QString', 'int', result='int')
    def newTask(self, text='', after=None):
        task = tasklib.Task(text)
        if bool(self._settings.value("Preferences/add_creation_date", False, type=bool)):
            task.addCreationDate()
        task.modified.connect(self._taskModified)
        if after is None:
            after = len(self._filteredTasks) - 1
        self._file.tasks.append(task)
        self._filteredTasks.insert(after + 1, task)  # force the new task to be visible
        self.setModified()
        self.auto_save()
        self.filteredTasksChanged.emit()
        return after + 1

    @QtCore.pyqtSlot('QVariant')
    def deleteTask(self, task):
        if not isinstance(task, tasklib.Task):
            # if task is not a task assume it is an int
            task = self.filteredTasks[task]
        self._file.tasks.remove(task)
        self.setModified()
        self.auto_save()
        self.applyFilters()  # update filtered list for UI

    @property
    def allTasks(self):
        return self._file.tasks

    filteredTasksChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('QVariant', notify=filteredTasksChanged)
    def filteredTasks(self):
        return self._filteredTasks

    showFutureChanged = QtCore.pyqtSignal('bool')

    @QtCore.pyqtProperty('bool', notify=showFutureChanged)
    def showFuture(self):
        return self._showFuture

    @showFuture.setter
    def showFuture(self, val):
        self._showFuture = val
        self.showFutureChanged.emit(val)
        self.applyFilters()

    searchTextChanged = QtCore.pyqtSignal(str)

    @QtCore.pyqtProperty('QString', notify=searchTextChanged)
    def searchText(self):
        return self._searchText

    @searchText.setter
    def searchText(self, txt):
        self._searchText = txt
        self.applyFilters()
        self.searchTextChanged.emit(txt)

    showCompletedChanged = QtCore.pyqtSignal('bool')

    @QtCore.pyqtProperty('bool', notify=showCompletedChanged)
    def showCompleted(self):
        return self._showCompleted

    @showCompleted.setter
    def showCompleted(self, val):
        self._showCompleted = val
        self.showCompletedChanged.emit(val)
        self.applyFilters()

    def auto_save(self):
        if bool(self._settings.value("Preferences/auto_save", True, type=bool)):
            self.save()

    def start(self):
        if self._args.file:
            filename = self._args.file
        else:
            filename = self._settings.value("last_open_file")

        if filename:
            try:
                self.open(filename)
            except OSError as ex:
                self.showError(str(ex))
        
        self.applyFilters()
        self._updateTitle()

    filtersUpdated = QtCore.pyqtSignal()  

    @QtCore.pyqtProperty('QVariant', notify=filtersUpdated)
    def filtersModel(self):
        return self._filters_tree_controller.model
   
    def _updateFilterTree(self):
        self._filters_tree_controller.showFilters(self._file)
        self.filtersUpdated.emit()

    def applyFilters(self):
        # First we filter with filters tree
        tasks = tasklib.filterTasks(self._currentFilters, self._file.tasks)
        # Then with our search text
        if self._searchText:
            tasks = tasklib.filterTasks([SimpleTextFilter(self._searchText)], tasks)
        # with future filter if needed
        if not self._showFuture:
            tasks = tasklib.filterTasks([FutureFilter()], tasks)
        # with complete filter if needed
        if not self._showCompleted and not CompleteTasksFilter() in self._currentFilters:
            tasks = tasklib.filterTasks([IncompleteTasksFilter()], tasks)
        self._filteredTasks = tasks
        self.filteredTasksChanged.emit()


    @QtCore.pyqtSlot()
    def archiveCompletedTasks(self):
        done = [task for task in self._file.tasks if task.is_complete]
        for task in done:
            self._file.saveDoneTask(task)
            self._file.tasks.remove(task)
        self.applyFilters()
        self.setModified()
        self.auto_save()

    modifiedChanged = QtCore.pyqtSignal(bool)

    @QtCore.pyqtProperty('bool', notify=modifiedChanged)
    def modified(self):
        return self._modified

    def setModified(self, val=True):
        self._modified = val
        self._updateTitle()
        if val:
            self._updateCompletionStrings()
            self._updateFilterTree()
        self.modifiedChanged.emit(val)

    @QtCore.pyqtSlot("QUrl")
    @QtCore.pyqtSlot()
    def save(self, path=None):
        if not path:
            path = self._file.filename
        elif isinstance(path, QtCore.QUrl):
            path = path.toLocalFile()
        self._file.filename = path

        logger.debug('MainController, saving file: %s.', path)
        try:
            self._file.save(path)
        except OSError as ex:
            logger.exception("Error saving file %s", path)
            self.showError(ex)
            return
        self._settings.setValue("last_open_file", path)
        self._settings.sync()
        self.setModified(False)

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
        return not self._modified

    def new(self):
        if self.canExit():
            self._file = File()
            self._loadFileToUI()

    @QtCore.pyqtSlot()
    def reload(self):
        self.open(self._file.filename)

    @QtCore.pyqtSlot('QUrl')
    @QtCore.pyqtSlot('QString')
    def open(self, filename):
        if isinstance(filename, QtCore.QUrl):
            filename = filename.toLocalFile()
        logger.debug('MainController.open called with filename="%s"', filename)
        try:
            self._file.load(filename)
        except Exception as ex:
            self.showError(self.tr("Error opening file: {}.\n Exception:{}").format(filename, ex))
            return
        self._loadFileToUI()
        self._settings.setValue("last_open_file", filename)
        for task in self._file.tasks:
            task.modified.connect(self._taskModified)
        self.applyFilters()
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
        self.applyFilters()
        self._updateCompletionStrings()
        self._updateFilterTree()
