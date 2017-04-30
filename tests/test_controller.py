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

    def test_open(self):
        self.ctrl.open("tests/todo1.txt")
        self.ctrl._applyFilters()
        print("TASK", self.ctrl.filteredTasks)
