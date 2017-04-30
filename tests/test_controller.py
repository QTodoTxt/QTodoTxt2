import unittest
from PyQt5 import QtCore
from datetime import date

from qtodotxt.lib import tasklib
from qtodotxt.lib.file import File
from qtodotxt.lib.filters import IncompleteTasksFilter, ContextFilter, ProjectFilter, DueThisMonthFilter, \
    DueThisWeekFilter, DueTodayFilter
from qtodotxt.controllers.main_controller import MainController


class Test(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.ctrl = MainController([])
        cls.ctrl.open("tests/todo1.txt")

    @classmethod
    def tearDownClass(cls):
        pass

    def test_completed(self):
        self.ctrl.showCompleted = True
        self.ctrl.applyFilters()
        self.assertEqual(self.ctrl.filteredTasks, self.ctrl.allTasks)
        self.ctrl.showCompleted = False
        self.ctrl.applyFilters()
        self.assertEqual(len(self.ctrl.filteredTasks), len(self.ctrl.allTasks) - 1)


