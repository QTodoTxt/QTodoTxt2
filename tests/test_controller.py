import unittest
from PyQt5 import QtCore
from datetime import date, timedelta

from qtodotxt.lib import tasklib
from qtodotxt.lib.file import File
from qtodotxt.lib.filters import IncompleteTasksFilter, ContextFilter, ProjectFilter, DueThisMonthFilter, \
    DueThisWeekFilter, DueTodayFilter
from qtodotxt.controllers.main_controller import MainController


class Test(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        QtCore.QCoreApplication.setOrganizationName("QTodoTxt")
        QtCore.QCoreApplication.setApplicationName("Testing")
        QtCore.QSettings().setValue("Preferences/auto_save", False)
        cls.ctrl = MainController([])
        cls.ctrl.allTasks = cls.make_tasks()
    
    @staticmethod
    def make_tasks():
        today = date.today().isoformat()
        tomorrow = (date.today() + timedelta(days=1)).isoformat()
        nextweek = (date.today() + timedelta(days=8)).isoformat()
        tasks = []
        t = tasklib.Task("(A) Task due:{} +project1 @context2".format(today))
        tasks.append(t)
        t = tasklib.Task("(B) Task due:{} +project2 @context1".format(tomorrow))
        tasks.append(t)
        t = tasklib.Task("Task due:{}".format(tomorrow))
        tasks.append(t)
        t = tasklib.Task("x (B) Task due:{} +project1 @context1".format(tomorrow))
        tasks.append(t)
        t = tasklib.Task("x (B) Task due:{} +project2 @context3".format(tomorrow))
        tasks.append(t)
        return tasks


    @classmethod
    def tearDownClass(cls):
        pass

    def test_completed(self):
        self.ctrl.showCompleted = True
        self.ctrl.applyFilters()
        self.assertEqual(self.ctrl.filteredTasks, self.ctrl.allTasks)
        self.ctrl.showCompleted = False
        self.ctrl.applyFilters()
        self.assertEqual(len(self.ctrl.filteredTasks), len(self.ctrl.allTasks) - 2)

    def test_new_delete(self):
        count = len(self.ctrl.allTasks)
        idx = self.ctrl.newTask("My funny new task + PeaceProject")
        self.assertEqual(count + 1,  len(self.ctrl.allTasks))
        task = self.ctrl.filteredTasks[idx]
        self.ctrl.deleteTask(task)
        self.assertEqual(count,  len(self.ctrl.allTasks))

    def test_filter(self):
        self.ctrl.setFilters([DueTodayFilter()])
        self.assertEqual(len(self.ctrl.filteredTasks), 1)
        self.ctrl.setFilters([])
