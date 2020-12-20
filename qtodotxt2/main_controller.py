import logging
import os
import string

from PyQt5 import QtCore

from qtodotxt2.lib import tasklib
from qtodotxt2.lib.file import File
from qtodotxt2.filters_controller import FiltersController

logger = logging.getLogger(__name__)


class MainController(QtCore.QObject):

    error = QtCore.pyqtSignal(str, arguments=["msg"])
    fileExternallyModified = QtCore.pyqtSignal()

    def __init__(self, args):
        super(MainController, self).__init__()
        self._args = args
        self._filteredTasks = []
        self._sortingMode = "default"
        # use object variable for setting only used in this class
        # others are accessed through QSettings
        self._settings = QtCore.QSettings()
        self._file = File()
        self._file.fileExternallyModified.connect(self.fileExternallyModified)
        self._file.fileModified.connect(self._fileModified)
        self.filtersController = FiltersController()
        self._title = "QTodoTxt2"
        self._recentFiles = self._settings.value("recent_files", [])
        self._updateCompletionStrings()
        self._forced = None

    def showError(self, msg):
        logger.debug("ERROR: %s", msg)
        self.error.emit(msg)

    completionChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('QStringList', notify=completionChanged)
    def completionStrings(self):
        return self._completionStrings

    @QtCore.pyqtProperty('QStringList', notify=completionChanged)
    def calendarKeywords(self):
        return ['due:', 't:']

    def _updateCompletionStrings(self):
        contexts = ['@' + name for name in self._file.getAllContexts()]
        projects = ['+' + name for name in self._file.getAllProjects()]
        lowest_priority = self._settings.value("lowest_priority", "D")
        idx = string.ascii_uppercase.index(lowest_priority) + 1
        priorities = ['(' + val + ')' for val in string.ascii_uppercase[:idx]]
        keywords = ['rec:', 'h:1'] #['due:', 't:', 'rec:', 'h:1']
        self._completionStrings = contexts + projects + priorities + self.calendarKeywords + keywords
        self.completionChanged.emit()

    @QtCore.pyqtSlot('QModelIndexList')
    def filterByIndexes(self, idxs):
        self.filtersController.setFiltersByIndexes(idxs)
        self.applyFilters()

    @QtCore.pyqtSlot('QString', 'int', result='int')
    def newTask(self, text='', after=None):
        task = tasklib.Task(text)
        if bool(self._settings.value("Preferences/add_creation_date", False, type=bool)):
            task.addCreationDate()
        if after is None:
            after = len(self._filteredTasks) - 1
        #self._file.addTask(task)
        self._filteredTasks.insert(after + 1, task)  # force the new task to be visible
        self._file.tasks.append(task)

        self._file.connectTask(task)  #Ensure task will be added
        self.filteredTasksChanged.emit()
        return after + 1

    @QtCore.pyqtSlot('QModelIndexList')
    @QtCore.pyqtSlot('QVariantList')
    def deleteTasks(self, tasks):
        new_tasks = []
        for task in tasks:
            if isinstance(task, tasklib.Task):
                t = task
            else:
                t = self._filteredTasks[int(task)]
            new_tasks.append(t)
        for task in new_tasks:
            self._file.deleteTask(task)

    @property
    def allTasks(self):
        return self._file.tasks

    @allTasks.setter
    def allTasks(self, tasks):
        self._file.tasks = tasks

    filteredTasksChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('QVariant', notify=filteredTasksChanged)
    def filteredTasks(self):
        return self._filteredTasks

    showFutureChanged = QtCore.pyqtSignal('bool')

    @QtCore.pyqtProperty('bool', notify=showFutureChanged)
    def showFuture(self):
        return self.filtersController.showFuture

    @showFuture.setter
    def showFuture(self, val):
        self.filtersController.showFuture = val
        self.showFutureChanged.emit(val)
        self.applyFilters()

    showHiddenChanged = QtCore.pyqtSignal('bool')

    @QtCore.pyqtProperty('bool', notify=showHiddenChanged)
    def showHidden(self):
        return self.filtersController.showHidden

    @showHidden.setter
    def showHidden(self, val):
        self.filtersController.showHidden = val
        self.showHiddenChanged.emit(val)
        self.applyFilters()

    sortingModeChanged = QtCore.pyqtSignal(str)

    @QtCore.pyqtProperty(str, notify=showFutureChanged)
    def sortingMode(self):
        return self._sortingMode

    @sortingMode.setter
    def sortingMode(self, val):
        self._sortingMode = val
        self.sortingModeChanged.emit(val)
        self.applyFilters()

    searchTextChanged = QtCore.pyqtSignal(str)

    @QtCore.pyqtProperty('QString', notify=searchTextChanged)
    def searchText(self):
        return self.filtersController.searchText

    @searchText.setter
    def searchText(self, txt):
        self.filtersController.searchText = txt
        self.applyFilters()
        self.searchTextChanged.emit(txt)

    showCompletedChanged = QtCore.pyqtSignal('bool')

    @QtCore.pyqtProperty('bool', notify=showCompletedChanged)
    def showCompleted(self):
        return self.filtersController.showCompleted

    @showCompleted.setter
    def showCompleted(self, val):
        self.filtersController.showCompleted = val
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
        return self.filtersController.model

    def _updateFilterTree(self):
        self.filtersController.updateFiltersModel(self._file)
        self.filtersUpdated.emit()

    def applyFilters(self, filters=None):
        if filters is not None:
            self.filtersController.setFilters(filters)
        tasks = self.filtersController.filter(self._file.tasks)
        tasks = getattr(tasklib.TaskSorter, self._sortingMode)(tasks)
        print("filteredTasks about to change in python")
        self._filteredTasks = tasks
        self.filteredTasksChanged.emit()

    @QtCore.pyqtSlot()
    def archiveCompletedTasks(self):
        done = [task for task in self._file.tasks if task.is_complete]
        for task in done:
            self._file.saveDoneTask(task)
            self._file.deleteTask(task)
        self.applyFilters()
        self.auto_save()

    modifiedChanged = QtCore.pyqtSignal(bool)

    @QtCore.pyqtProperty('bool', notify=modifiedChanged)
    def modified(self):
        return self._file.modified

    def _fileModified(self, val=True):
        if val:
            self.auto_save()
            self.applyFilters()
            self._updateCompletionStrings()
            self._updateFilterTree()
        self._updateTitle()
        self.modifiedChanged.emit(val)

    @QtCore.pyqtSlot("QUrl")
    @QtCore.pyqtSlot()
    def save(self, path=None):
        if not path:
            path = self._file.filename
        elif isinstance(path, QtCore.QUrl):
            path = path.toLocalFile()
        self._file.filename = path

#        logger.debug('MainController, saving file: %s.', path)
        try:
            self._file.save(path)
        except OSError as ex:
            logger.exception("Error saving file %s", path)
            self.showError(ex)
            return
        self._settings.setValue("last_open_file", path)
        self._settings.sync()

    def _updateTitle(self):
        title = 'QTodoTxt2 - '
        if self._file.filename:
            filename = os.path.basename(self._file.filename)
            title += filename
        else:
            title += 'Untitled'
        if self._file.modified:
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
        return not self._file.modified

    def new(self):
        if self.canExit():
            self._file = File()
            self._loadFileToUI()

    @QtCore.pyqtSlot(result='bool')
    def canAutoReload(self):
        return bool(self._settings.value("Preferences/auto_reload", False, type=bool))

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
        self.updateRecentFile()

    recentFilesChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('QVariant', notify=recentFilesChanged)
    def recentFiles(self):
        return self._recentFiles if self._recentFiles != [] else [""]

    def updateRecentFile(self):
        if self._file.filename in self._recentFiles:
            self._recentFiles.remove(self._file.filename)
        self._recentFiles.insert(0, self._file.filename)
        self._recentFiles = self._recentFiles[:int(self._settings.value("max_recent_files", 6))]
        self._settings.setValue("recent_files", self._recentFiles)
        self.recentFilesChanged.emit()

    def _loadFileToUI(self):
        self.applyFilters()
        self._updateCompletionStrings()
        self._updateFilterTree()

    @QtCore.pyqtSlot('QModelIndexList')
    @QtCore.pyqtSlot('QVariantList')
    def completeTasks(self, tasks):
        for task in tasks:
            if not isinstance(task, tasklib.Task):
                # if task is not a task assume it is an int
                task = self._filteredTasks[int(task)]
            if not task.is_complete:
                if task.recursion is not None and task.due is not None:
                    new_task = tasklib.recurTask(task)
                    self._file.addTask(new_task)
                task.setCompleted()
            else:
                task.setPending()

    docPathChanged = QtCore.pyqtSignal()

    @QtCore.pyqtProperty('QUrl', notify=docPathChanged)
    def docPath(self):
        return QtCore.QUrl(QtCore.QStandardPaths.writableLocation(QtCore.QStandardPaths.DocumentsLocation))


