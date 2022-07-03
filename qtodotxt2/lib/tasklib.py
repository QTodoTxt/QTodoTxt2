from datetime import datetime, date, time, MAXYEAR, timedelta
from dateutil.relativedelta import relativedelta

import re
from enum import Enum

from PyQt5 import QtCore

from qtodotxt2.lib.task_htmlizer import TaskHtmlizer


class RecursiveMode(Enum):
    completionDate = 0  # Original due date mode: Task recurs from original due date
    originalDueDate = 1  # Completion date mode: Task recurs from completion date


class Recursion:
    mode = None
    increment = None
    interval = None

    def __init__(self, arg_mode, arg_increment, arg_interval):
        self.mode = arg_mode
        self.increment = arg_increment
        self.interval = arg_interval


class TaskSorter(object):
    
    @staticmethod
    def projects(tasks):
        def tmp(task):
            prj = task.projects if task.projects else ["zz"]
            return prj, task
        return sorted(tasks, key=tmp)

    @staticmethod
    def contexts(tasks):
        def tmp(task):
            ctx = task.contexts if task.contexts else ["zz"]
            return ctx, task
        return sorted(tasks, key=tmp)

    @staticmethod
    def due(tasks):
        def tmp(task):
            if task.due:
                return task.due, task
            else:
                return datetime(MAXYEAR, 1, 1), task
        return sorted(tasks, key=tmp, reverse=False)

    @staticmethod
    def default(tasks):
        return sorted(tasks, reverse=False)


class Task(QtCore.QObject):
    """
    Represent a task as defined in todo.txt format
    Take a line in todo.txt format as argument
    Arguments are read-only, reparse string to modify them or
    use one the modification methods such as setCompleted()
    """

    modified = QtCore.pyqtSignal(object)

    def __init__(self, text):
        QtCore.QObject.__init__(self)
        self._settings = QtCore.QSettings()
        self._highest_priority = 'A'
        # all other class attributes are defined in _reset method
        # which is called in _parse
        self._parse(text)

    def addCreationCate(self):
        self._removeCreationDate()
        self._addCreationDate()

    def __str__(self):
        return self._text

    def __repr__(self):
        return "Task({})".format(self._text)

    def _removeCreationDate(self):
        match = re.match(r'^(\([A-Z]\)\s)?[0-9]{4}\-[0-9]{2}\-[0-9]{2}\s(.*)', self._text)
        if match:
            if match.group(1):
                self._text = match.group(1) + match.group(2)
            else:
                self._text = match.group(2)

    def addCreationDate(self):
        date_string = date.today().strftime('%Y-%m-%d')
        if re.match(r'^\([A-Z]\)', self._text):
            self._text = '%s %s %s' % (self._text[:3], date_string, self._text[4:])
        else:
            self._text = '%s %s' % (date_string, self._text)

    def _reset(self):
        self.contexts = []
        self.projects = []
        self._priority = ""
        self.is_complete = False
        self.completion_date = None
        self.creation_date = None
        self.is_future = False
        self._threshold = None
        self.threshold_error = ""
        self._text = ''
        self.description = ''
        self._due = None
        self._due_error = ""
        self.keywords = {}
        self.recursion = None
        self._hidden = False

    def _parse(self, line):
        """
        parse a task formated as string in todo.txt format
        """
        self._reset()
        words = line.split(' ')
        if words[0] == "x":
            self.is_complete = True
            words = words[1:]
            # parse next word as a completion date
            # required by todotxt but often not here
            self.completion_date = _parseDate(words[0])
            if self.completion_date:
                words = words[1:]
        elif re.search(r'^\([A-Z]\)$', words[0]):
            self._priority = words[0][1:-1]
            words = words[1:]

        if 'h:1' in line:
            self._hidden = True

        dato = _parseDate(words[0])
        if dato:
            self.creation_date = dato
            words = words[1:]

        self.description = " ".join(words)
        for word in words:
            self._parseWord(word)
        self._text = line

    @QtCore.pyqtProperty('QString', notify=modified)
    def text(self):
        return self._text

    @text.setter
    def text(self, txt):
        self._parse(txt)
        self.modified.emit(self)

    @QtCore.pyqtProperty('QString', notify=modified)
    def html(self):
        return self.toHtml()

    @QtCore.pyqtProperty(bool, notify=modified)
    def hidden(self):
        return self._hidden

    @hidden.setter
    def hidden(self, val):
        if self._hidden == val:
            return
        if val:
            self.text = self._text + ' h:1'
        else:
            txt = self._text.replace(' h:1', '')
            self.text = txt.replace('h:1', '')  # also take the case whe h_1 is at the beginning

    @QtCore.pyqtProperty('QString', notify=modified)
    def priority(self):
        return self._priority
    
    @QtCore.pyqtProperty('QString', notify=modified)
    def priorityHtml(self):
        htmlizer = TaskHtmlizer()
        return htmlizer._htmlizePriority(self.priority)

    def _parseWord(self, word):
        if len(word) > 1:
            if word.startswith('@'):
                self.contexts.append(word[1:])
            elif word.startswith('+'):
                self.projects.append(word[1:])
            elif ":" in word:
                self._parseKeyword(word)

    def _parseKeyword(self, word):
        key, val = word.split(":", 1)
        self.keywords[key] = val
        if word.startswith('due:'):
            self._due = _parseDateTime(word[4:])
            if not self._due:
                print("Error parsing due date '{}'".format(word))
                self._due_error = word[4:]
        elif word.startswith('t:'):
            self._parseFuture(word)
        elif word.startswith('rec:'):
            self._parseRecurrence(word)

    def _parseFuture(self, word):
        self._threshold = _parseDateTime(word[2:])
        if not self._threshold:
            print("Error parsing threshold '{}'".format(word))
            self.threshold_error = word[2:]
        else:
            if self._threshold > datetime.today():
                self.is_future = True

    def _parseRecurrence(self, word):
        # Original due date mode
        if word[4] == '+':
            # check correct format for strict recurrence (with the leading '+')
            # allow 1 or more digits for increment
            if re.match('^[1-9]+[bdwmy]', word[5:]):
                # send all digits as increment and last char as interval
                self.recursion = Recursion(RecursiveMode.originalDueDate, word[5:-1], word[-1])
            else:
                print("Error parsing recurrence '{}'".format(word))
        # Completion mode
        else:
            # same as above for "normal recurrence" (without leading '+')
            if re.match('^[1-9]+[bdwmy]', word[4:]):
                self.recursion = Recursion(RecursiveMode.completionDate, word[4:-1], word[-1])
            else:
                print("Error parsing recurrence '{}'".format(word))
    
    @property
    def due(self):
        return self._due

    @due.setter
    def due(self, val):
        if isinstance(val, datetime):
            val = dateString(val)
        self.text = self._replace_date(self._text, val, 'due')

    @property
    def dueString(self):
        return dateString(self._due)

    @property
    def threshold(self):
        return self._threshold

    @threshold.setter
    def threshold(self, val):
        if isinstance(val, datetime):
            val = dateString(val)
        self.text = self._replace_date(self._text, val, 't')

    @staticmethod
    def _replace_date(text, date_text, prefix):
        return re.sub(r'\s' + prefix + r'\:[0-9]{4}\-[0-9]{2}\-[0-9]{2}', ' {}:{}'.format(prefix, date_text), text)


    @property
    def thresholdString(self):
        return dateString(self._threshold)

    @QtCore.pyqtSlot()
    def toggleCompletion(self):
        if self.is_complete:
            self.setPending()
        else:
            self.setCompleted()

    def setCompleted(self):
        """
        Set a task as completed by inserting a x and current date at the begynning of line
        """
        if self.is_complete:
            return
        self.completion_date = date.today()
        date_string = self.completion_date.strftime('%Y-%m-%d')
        self._text = 'x %s %s' % (date_string, self._text)
        self.is_complete = True
        self.modified.emit(self)

    def setPending(self):
        """
        Unset completed flag from task
        """
        if not self.is_complete:
            return
        words = self._text.split(" ")
        d = _parseDate(words[1])
        if d:
            self._text = " ".join(words[2:])
        else:
            self._text = " ".join(words[1:])
        self.is_complete = False
        self.completion_date = None
        self.modified.emit(self)

    def toHtml(self):
        """
        return a task as an html block which is a pretty display of a line in todo.txt format
        """
        htmlizer = TaskHtmlizer()
        return htmlizer.task2html(self)

    def _getLowestPriority(self):
        return self._settings.value("Preferences/lowest_priority", "D")

    @QtCore.pyqtSlot()
    def increasePriority(self):
        lowest_priority = self._getLowestPriority()
        if self.is_complete:
            return
        if not self._priority:
            self._priority = lowest_priority
            self._text = "({}) {}".format(self._priority, self._text)
        elif self._priority != self._highest_priority:
            self._priority = chr(ord(self._priority) - 1)
            self._text = "({}) {}".format(self._priority, self._text[4:])
        self.modified.emit(self)

    @QtCore.pyqtSlot()
    def decreasePriority(self):
        lowest_priority = self._getLowestPriority()
        if self.is_complete:
            return
        if self._priority >= lowest_priority:
            self._priority = ""
            self._text = self._text[4:]
            self._text = self._text.replace("({})".format(self._priority), "", 1)
        elif self._priority:
            oldpriority = self._priority
            self._priority = chr(ord(self._priority) + 1)
            self._text = self._text.replace("({})".format(oldpriority), "({})".format(self._priority), 1)
        self.modified.emit(self)

    def __eq__(self, other):
        return self._text == other.text

    def __lt__(self, other):
        prio1 = self.priority if self.priority else "z"
        prio2 = other.priority if other.priority else "z"
        return (self.is_complete, prio1, self._text) < (other.is_complete, prio2, other.text)


def dateString(dato):
    """
    Return a datetime as a nicely formatted string
    """
    if dato.time() == time.min:
        return dato.strftime('%Y-%m-%d')
    else:
        return dato.strftime('%Y-%m-%d %H:%M')


def _incrWorkDays(startDate, daysToIncrement):
    while daysToIncrement > 0:
        if startDate.weekday() == 4:  # Friday
            startDate = startDate + timedelta(days=3)
        elif startDate.weekday() == 5:  # Saturday
            startDate = startDate + timedelta(days=2)
        else:
            startDate = startDate + timedelta(days=1)
        daysToIncrement -= 1
    return startDate


def _recurWorkDays(task):
    if task.recursion.mode == RecursiveMode.originalDueDate:
        next_due_date = _incrWorkDays(task.due, int(task.recursion.increment))
    else:
        next_due_date = _incrWorkDays(date.today(), int(task.recursion.increment))
    new = Task(task.text)
    new.due = next_due_date
    if new.threshold:
        delta2 = task.due - task.threshold  #FIXME: this might be wrong, maybe we should add weekends...
        new.threshold = new.due
        new.threshold += delta2
    return new


def recurTask(task):
    """
    Create the next task from a recurring task
    """
    if task.recursion.interval == 'd':
        delta = timedelta(days=int(task.recursion.increment))
    elif task.recursion.interval == 'b':
        # special case
        return _recurWorkDays(task)
    elif task.recursion.interval == 'w':
        delta = timedelta(weeks=int(task.recursion.increment))
    elif task.recursion.interval == 'm':
        delta = relativedelta(months=int(task.recursion.increment))  # 1 month in a month, not 4 weeks
    elif task.recursion.interval == 'y':
        delta = relativedelta(years=int(task.recursion.increment))  # 1 year in a year, not 52 weeks
    else:
        # Test already made during line parsing - shouldn't be a problem here
        pass
    # Set new due date in old task text
    new = Task(task.text)
    if task.recursion.mode == RecursiveMode.originalDueDate:
        new.due += delta
        if new.threshold:
            new.threshold += delta
    else:
        new.due = date.today() + delta
        if new.threshold:
            delta2 = task.due - task.threshold
            new.threshold += delta2
    return new


def _parseDate(string):
    try:
        return datetime.strptime(string, '%Y-%m-%d').date()
    except ValueError:
        return None


def _parseDateTime(string):
    try:
        return datetime.strptime(string, '%Y-%m-%d')
    except ValueError:
        try:
            return datetime.strptime(string, '%Y-%m-%dT%H:%M')
        except ValueError:
            return None


