import unittest
from PyQt5 import QtCore
from datetime import date, timedelta

from qtodotxt2.lib import tasklib
from qtodotxt2.lib.file import File
from qtodotxt2.lib.filters import IncompleteTasksFilter, ContextFilter, ProjectFilter, DueThisMonthFilter, \
    DueThisWeekFilter, DueTodayFilter, DueOverdueFilter
from qtodotxt2.main_controller import MainController


class Test(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        QtCore.QCoreApplication.setOrganizationName("QTodoTxt")
        QtCore.QCoreApplication.setApplicationName("Testing")
        QtCore.QSettings().setValue("Preferences/auto_save", False)
        QtCore.QSettings().setValue("Preferences/match_only_beginnings_of_words_when_filtering", True)
        cls.ctrl = MainController([])
        cls.ctrl.allTasks = cls.make_tasks()
        cls.ctrl.showCompleted = True
    
    @staticmethod
    def make_tasks():
        today = date.today().isoformat()
        tomorrow = (date.today() + timedelta(days=1)).isoformat()
        nextweek = (date.today() + timedelta(days=8)).isoformat()
        tasks = []
        t = tasklib.Task("(A) Task home due:{} +project1 @context2".format(today))
        tasks.append(t)
        t = tasklib.Task("(B) Task due:{} +project2 @context1".format(tomorrow))
        tasks.append(t)
        t = tasklib.Task("Task due:2015-04-01 +project2 @context1")
        tasks.append(t)
        t = tasklib.Task("TOTO due:2015-04-02 +project3")
        tasks.append(t)
        t = tasklib.Task("TOTO due:{}".format(tomorrow))
        tasks.append(t)
        t = tasklib.Task("x (B) Task due:{} +project1 @context1".format(tomorrow))
        tasks.append(t)
        t = tasklib.Task("x (B) Task due:{} +project2 @context3".format(tomorrow))
        tasks.append(t)
        t = tasklib.Task("(B) Task home +project2 @context3")
        tasks.append(t)
        t = tasklib.Task("りんごを購入する") # This sentence means "Buy an apple" in Japanese.
        tasks.append(t)
        return tasks


    @classmethod
    def tearDownClass(cls):
        pass

    def test_completed(self):
        self.ctrl.showCompleted = True
        self.ctrl.applyFilters()
        self.assertEqual(len(self.ctrl.filteredTasks), len(self.ctrl.allTasks))
        self.ctrl.showCompleted = False
        self.ctrl.applyFilters()
        self.assertEqual(len(self.ctrl.filteredTasks), len(self.ctrl.allTasks) - 2)
        self.ctrl.showCompleted = True

    def test_new_delete(self):
        count = len(self.ctrl.allTasks)
        idx = self.ctrl.newTask("My funny new task + PeaceProject")
        self.assertEqual(count + 1,  len(self.ctrl.allTasks))
        task = self.ctrl.filteredTasks[idx]
        self.ctrl.deleteTasks([task])
        self.assertEqual(count,  len(self.ctrl.allTasks))

    def test_filter(self):
        self.ctrl.applyFilters([DueTodayFilter()])
        self.assertEqual(len(self.ctrl.filteredTasks), 1)
        print("START")
        self.ctrl.applyFilters([DueOverdueFilter()])
        self.assertEqual(len(self.ctrl.filteredTasks), 2)
        self.ctrl.applyFilters([])

    def test_filter_string(self):
        self.ctrl.searchText = "home"
        self.assertEqual(len(self.ctrl.filteredTasks), 2)
        self.ctrl.searchText = "+project2"
        self.assertEqual(len(self.ctrl.filteredTasks), 4)
        self.ctrl.searchText = "!due home"
        self.assertEqual(len(self.ctrl.filteredTasks), 1)
        self.ctrl.searchText = "2015"
        self.assertEqual(len(self.ctrl.filteredTasks), 2)
        QtCore.QSettings().setValue("Preferences/match_only_beginnings_of_words_when_filtering", False)
        self.ctrl.searchText = "購入"
        self.assertEqual(len(self.ctrl.filteredTasks), 1)
        self.ctrl.searchText = "home"
        self.assertEqual(len(self.ctrl.filteredTasks), 2)
        self.ctrl.searchText = "+project2"
        self.assertEqual(len(self.ctrl.filteredTasks), 4)
        self.ctrl.searchText = "!due home"
        self.assertEqual(len(self.ctrl.filteredTasks), 1)
        self.ctrl.searchText = "2015"
        self.assertEqual(len(self.ctrl.filteredTasks), 2)
        QtCore.QSettings().setValue("Preferences/match_only_beginnings_of_words_when_filtering", True)
        self.ctrl.searchText = "購入"
        self.assertEqual(len(self.ctrl.filteredTasks), 0)
        self.ctrl.searchText = ""

    def test_filter_or(self):
        self.ctrl.searchText = "home | TOTO"
        self.assertEqual(len(self.ctrl.filteredTasks), 4)
