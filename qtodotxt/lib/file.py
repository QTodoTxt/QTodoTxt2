import logging
import os

from PyQt5 import QtCore

from qtodotxt.lib.filters import DueTodayFilter, DueTomorrowFilter, DueThisWeekFilter, DueThisMonthFilter, DueOverdueFilter
from qtodotxt.lib.tasklib import Task

logger = logging.getLogger(__name__)


class File(QtCore.QObject):

    fileModified = QtCore.pyqtSignal()

    def __init__(self):
        QtCore.QObject.__init__(self)
        self.newline = '\n'
        self.tasks = []
        self.filename = ''
        self._fileObserver = FileObserver(self)
        self._fileObserver.fileChangetSig.connect(self.fileModified)

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

    def save(self, filename=''):
        logger.debug('File.save called with filename="%s"', filename)
        self._fileObserver.clear()
        if not filename and not self.filename:
            self.filename = self._createNewFilename()
        elif filename:
            self.filename = filename
        self.tasks.sort(reverse=True)
        self._saveTasks()
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
        logger.debug('%s was saved to disk.', self.filename)

    def saveDoneTask(self, task):
        doneFilename = os.path.join(os.path.dirname(self.filename), 'done.txt')
        with open(doneFilename, 'at', encoding='utf-8') as fd:
            fd.write(task.text + self.newline)
        logger.debug('"%s" was appended to "%s"', task.text, doneFilename)

    def getAllContexts(self, return_completed=False):
        contexts = dict()
        for task in self.tasks:
            if return_completed or not task.is_complete:
                for context in task.contexts:
                    count = 0 if task.is_complete else 1
                    if context in contexts:
                        contexts[context] += count
                    else:
                        contexts[context] = count
        return contexts

    def getAllProjects(self, return_completed=False):
        projects = dict()
        for task in self.tasks:
            if return_completed or not task.is_complete:
                for project in task.projects:
                    count = 0 if task.is_complete else 1
                    if project in projects:
                        projects[project] += count
                    else:
                        projects[project] = count
        return projects

    def getAllPriorities(self, return_completed=False):
        priorities = {}
        for task in self.tasks:
            if return_completed or not task.is_complete:
                if task.priority in priorities:
                    priorities[task.priority] += 1
                elif task.priority != "":
                    priorities[task.priority] = 1

        return priorities

    def getAllDueRanges(self, return_completed=False):
        dueRanges = dict()
        # This determines the sorting of the ranges in the tree view. Lowest value first.
        rangeSorting = {'Today': 20,
                        'Tomorrow': 30,
                        'This week': 40,
                        'This month': 50,
                        'Overdue': 10}

        for task in self.tasks:
            if not return_completed and task.is_complete:
                continue

            count = 0 if task.is_complete else 1
            if DueTodayFilter('Today').isMatch(task):
                if not ('Today' in dueRanges):
                    dueRanges['Today'] = count
                else:
                    dueRanges['Today'] += count

            if DueTomorrowFilter('Tomorrow').isMatch(task):
                if not ('Tomorrow' in dueRanges):
                    dueRanges['Tomorrow'] = count
                else:
                    dueRanges['Tomorrow'] += count

            if DueThisWeekFilter('This week').isMatch(task):
                if not ('This week' in dueRanges):
                    dueRanges['This week'] = count
                else:
                    dueRanges['This week'] += count

            if DueThisMonthFilter('This month').isMatch(task):
                if not ('This month' in dueRanges):
                    dueRanges['This month'] = count
                else:
                    dueRanges['This month'] += count

            if DueOverdueFilter('Overdue').isMatch(task):
                if not ('Overdue' in dueRanges):
                    dueRanges['Overdue'] = count
                else:
                    dueRanges['Overdue'] += count

        return dueRanges, rangeSorting

    def getTasksCounters(self):
        counters = dict({'Pending': 0,
                         'Uncategorized': 0,
                         'Contexts': 0,
                         'Projects': 0,
                         'Complete': 0,
                         'Priority': 0,
                         'DueCompl': 0,
                         'ProjCompl': 0,
                         'ContCompl': 0,
                         'UncatCompl': 0,
                         'PrioCompl': 0,
                         'Due': 0})
        for task in self.tasks:
            nbProjects = len(task.projects)
            nbContexts = len(task.contexts)
            if not task.is_complete:
                counters['Pending'] += 1
                if nbProjects > 0:
                    counters['Projects'] += 1
                if nbContexts > 0:
                    counters['Contexts'] += 1
                if nbContexts == 0 and nbProjects == 0:
                    counters['Uncategorized'] += 1
                if task.due:
                    counters['Due'] += 1
                if task.priority != "":
                    counters['Priority'] += 1
            else:
                counters['Complete'] += 1
                if nbProjects > 0:
                    counters['ProjCompl'] += 1
                if nbContexts > 0:
                    counters['ContCompl'] += 1
                if nbContexts == 0 and nbProjects == 0:
                    counters['UncatCompl'] += 1
                if task.due:
                    counters['DueCompl'] += 1
                if task.priority != "":
                    counters['PrioCompl'] += 1
        return counters


class FileObserver(QtCore.QFileSystemWatcher):

    fileChangetSig = QtCore.pyqtSignal(str)
    dirChangetSig = QtCore.pyqtSignal(str)

    def __init__(self, mfile):
        logger.debug('Setting up FileObserver instance.')
        super().__init__(mfile)
        self._file = mfile
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
            logger.debug('Clearing watchlist.')
            self.removePaths(self.files())
