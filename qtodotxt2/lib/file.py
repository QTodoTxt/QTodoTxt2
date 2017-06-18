import logging
import os

from PyQt5 import QtCore

from qtodotxt2.lib.filters import DueTodayFilter, DueTomorrowFilter, DueThisWeekFilter, DueThisMonthFilter, DueOverdueFilter
from qtodotxt2.lib.tasklib import Task

logger = logging.getLogger(__name__)


class File(QtCore.QObject):

    fileExternallyModified = QtCore.pyqtSignal()
    fileModified = QtCore.pyqtSignal(bool)

    def __init__(self):
        QtCore.QObject.__init__(self)
        self.newline = '\n'
        self.tasks = []
        self.filename = ''
        self._fileObserver = FileObserver()
        self._fileObserver.fileChangetSig.connect(self.fileExternallyModified)
        self.modified = False

    def __str__(self):
        return "File(filename:{}, tasks:{})".format(self.filename, self.tasks)

    __repr__ = __str__

    def load(self, filename):
        self._fileObserver.clear()
        with open(filename, 'rt', encoding='utf-8') as fd:
            lines = fd.readlines()
        self.filename = filename
        self._createTasksFromLines(lines)
        self._fileObserver.addPath(self.filename)

    def _createTasksFromLines(self, lines):
        self.tasks = []
        for line in lines:
            task_text = line.strip()
            if task_text:
                task = Task(task_text)
                self.tasks.append(task)
                task.modified.connect(self._taskModified)

    def _taskModified(self, task):
        self.setModified(True)
        #if task not in self.tasks:
            #self.tasks.append(task)
        if not task.text:
            self.deleteTask(task)

    def setModified(self, val):
        self.modified = val
        self.fileModified.emit(val)

    def deleteTask(self, task):
        self.tasks.remove(task)
        self.setModified(True)

    def addTask(self, task):
        self.tasks.append(task)
        task.modified.connect(self._taskModified)
        self.setModified(True)

    def connectTask(self, task):
        task.modified.connect(self._taskModified)

    def save(self, filename=''):
#        logger.debug('File.save called with filename="%s"', filename)
        self._fileObserver.clear()
        if not filename and not self.filename:
            self.filename = self._createNewFilename()
        elif filename:
            self.filename = filename
        self.tasks = sorted(self.tasks)  # we sort for users using simple text editors
        self._saveTasks()
        self.modified = False
        self.fileModified.emit(False)
        self._fileObserver.addPath(self.filename)

    @staticmethod
    def _createNewFilename():
        newFileName = os.path.expanduser('~/todo.txt')
        if not os.path.isfile(newFileName):
            return newFileName
        for counter in range(0, 100):
            newFileName = os.path.expanduser('~/todo.{}.txt.'.format(counter))
            if not os.path.isfile(newFileName):
                return newFileName
        return os.path.expanduser('~/todo.0.txt')

    def _saveTasks(self):
        with open(self.filename, 'wt', encoding='utf-8') as fd:
            fd.writelines([(task.text + self.newline) for task in self.tasks])
#        logger.debug('%s was saved to disk.', self.filename)

    def saveDoneTask(self, task):
        doneFilename = os.path.join(os.path.dirname(self.filename), 'done.txt')
        with open(doneFilename, 'at', encoding='utf-8') as fd:
            fd.write(task.text + self.newline)
        logger.debug('"%s" was appended to "%s"', task.text, doneFilename)

    def getAllContexts(self):
        return self._getAllX("contexts")

    def getAllProjects(self):
        return self._getAllX("projects")

    def _getAllX(self, name):
        res = {}
        for task in self.tasks:
            for element in getattr(task, name):
                if element not in res:
                    res[element] = [0, 0]
                idx = 1 if task.is_complete else 0
                res[element][idx] += 1
        return res

    def getAllPriorities(self):
        return self._getAllX("priority")

    def getAllDueRanges(self):
        dueRanges = dict()
        filters = [DueTodayFilter(), DueTomorrowFilter(), DueThisWeekFilter(), DueThisMonthFilter(), DueOverdueFilter()]
        for task in self.tasks:
            idx = 1 if task.is_complete else 0
            for flt in filters:
                if flt.isMatch(task):
                    if not (flt in dueRanges):
                        dueRanges[flt] = [0, 0]
                    dueRanges[flt][idx] += 1
        return dueRanges

    def getTasksCounters(self):
        counters = dict({
            'All': [0, 0],
            'Uncategorized': [0, 0],
            'Contexts': [0, 0],
            'Projects': [0, 0],
            'Complete': [0, 0],
            'Priority': [0, 0],
            'Due': [0, 0]
        })
        for task in self.tasks:
            nbProjects = len(task.projects)
            nbContexts = len(task.contexts)
            idx = 1 if task.is_complete else 0
            counters['All'][idx] += 1
            if nbProjects > 0:
                counters['Projects'][idx] += 1
            if nbContexts > 0:
                counters['Contexts'][idx] += 1
            if nbContexts == 0 and nbProjects == 0:
                counters['Uncategorized'][idx] += 1
            if task.due:
                counters['Due'][idx] += 1
            if task.priority != "":
                counters['Priority'][idx] += 1
        return counters


class FileObserver(QtCore.QFileSystemWatcher):

    fileChangetSig = QtCore.pyqtSignal(str)
    dirChangetSig = QtCore.pyqtSignal(str)

    def __init__(self):
        logger.debug('Setting up FileObserver instance.')
        super().__init__()
        self.fileChanged.connect(self.fileChangedHandler)
        self.directoryChanged.connect(self.dirChangedHandler)

    def fileChangedHandler(self, path):
        logger.debug('Detected external file change for file %s', path)
        self.removePath(path)
        self.fileChangetSig.emit(path)

    def dirChangedHandler(self, path):
        logger.debug('Detected directory change for file %s', path)
        self.dirChangetSig.emit(path)

    def clear(self):
        if self.files():
#            logger.debug('Clearing watchlist.')
            self.removePaths(self.files())
