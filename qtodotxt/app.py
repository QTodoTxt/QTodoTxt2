#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import logging
import sys
import os

from PyQt5 import QtCore, QtGui
from PyQt5 import QtWidgets
#imports for QML integration
from PyQt5.QtQml import qmlRegisterType, QQmlComponent, QQmlApplicationEngine

# import resource for darkstyle
# taken from https://github.com/ColinDuquesnoy/QDarkStyleSheet
import qtodotxt.ui.pyqt5_style_rc  # noqa: F401
import qtodotxt.ui.qTodoTxt_style_rc  # noqa: F401
import qtodotxt.ui.qTodoTxt_dark_style_rc  # noqa: F401

from qtodotxt.controllers.main_controller import MainController
from qtodotxt.lib.file import FileObserver
from qtodotxt.lib.tendo_singleton import SingleInstance

#(Just for testing how to communicate between python and qml, see also below)
from qtodotxt.qml_class import MainControllerQml


def _parseArgs():
    if len(sys.argv) > 1 and sys.argv[1].startswith('-psn'):
        del sys.argv[1]
    parser = argparse.ArgumentParser(description='QTodoTxt')
    parser.add_argument('file', type=str, nargs='?', metavar='TEXTFILE', help='open the specified file')
    parser.add_argument(
        '-q', '--quickadd', action='store_true', help='opens the add task dialog and exit the application when done')
    parser.add_argument(
        '-l',
        '--loglevel',
        type=str,
        nargs=1,
        metavar='LOGLEVEL',
        default=['WARN'],
        choices=['DEBUG', 'INFO', 'WARNING', 'WARN', 'ERROR', 'CRITICAL'],
        help='set one of these logging levels: DEBUG, INFO, WARNING, ERROR, CRITICAL')
    return parser.parse_args()


def _setupLogging(loglevel):
    numeric_level = getattr(logging, loglevel[0].upper(), None)
    if isinstance(numeric_level, int):
        logging.basicConfig(
            format='{asctime}.{msecs:.0f} [{name}] {levelname}: {message}',
            level=numeric_level,
            style='{',
            datefmt='%H:%M:%S')


def setupAnotherInstanceEvent(controller, dir):
    fileObserver = FileObserver(controller, dir)
    fileObserver.addPath(dir)
    fileObserver.dirChangetSig.connect(controller.anotherInstanceEvent)


def setupSingleton(args, me):
    dir = os.path.dirname(sys.argv[0])
    tempFileName = dir + "/qtodo.tmp"
    if me.initialized is True:
        if os.path.isfile(tempFileName):
            os.remove(tempFileName)
    else:
        f = open(tempFileName, 'w')
        if args.quickadd is False:
            f.write("1")
        if args.quickadd is True:
            f.write("2")
        f.flush()
        f.close()
        sys.exit(-1)


def run():
    # First set some application settings for QSettings
    QtCore.QCoreApplication.setOrganizationName("QTodoTxt")
    QtCore.QCoreApplication.setApplicationName("QTodoTxtDev")
    # Now set up our application and start
    app = QtWidgets.QApplication(sys.argv)
    #it is said, that this is lighter:
    #(without qwidgets, as we probably don't need them anymore, when transition to qml is done)
    #app = QtGui.QGuiApplication(sys.argv)

    name = QtCore.QLocale.system().name()
    translator = QtCore.QTranslator()
    if translator.load(str(name) + ".qm", "..//i18n"):
        app.installTranslator(translator)

    args = _parseArgs()

    dir = os.path.dirname(sys.argv[0])
    needSingleton = QtCore.QSettings().value("singleton", 0)

    # clear or write to TMP file, of main instance
    if int(needSingleton):
        me = SingleInstance()
        setupSingleton(args, me)

    _setupLogging(args.loglevel)

    engine = QQmlApplicationEngine()
    controller = MainController(args)
    engine.rootContext().setContextProperty("mainController", controller)
    path = os.path.dirname(__file__)
    engine.load(path + '/qml/QTodoTxt.qml')

    # Connecting to a processor reading TMP file
    if needSingleton:
        setupAnotherInstanceEvent(controller, dir)

    controller.start()
    app.exec_()
    sys.exit()


if __name__ == "__main__":
    run()
