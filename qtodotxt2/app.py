#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import logging
import sys
import os

from PyQt5 import QtCore
from PyQt5 import QtWidgets
from PyQt5.QtQml import QQmlApplicationEngine

import qtodotxt2.qTodoTxt_style_rc

from qtodotxt2.main_controller import MainController
from qtodotxt2.lib.file import FileObserver
from qtodotxt2.lib.tendo_singleton import SingleInstance


def _parseArgs():
    if len(sys.argv) > 1 and sys.argv[1].startswith('-psn'):
        del sys.argv[1]
    parser = argparse.ArgumentParser(description='QTodoTxt')
    parser.add_argument('file', type=str, nargs='?', metavar='TEXTFILE', help='open the specified file')
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


def setupAnotherInstanceEvent(controller):
    # Connecting to a processor reading TMP file
    needSingleton = QtCore.QSettings().value("Preferences/singleton", False, type=bool)
    if needSingleton:
        dirname = os.path.dirname(sys.argv[0])
        fileObserver = FileObserver()
        fileObserver.addPath(dirname)
        #FIXME maybe do something in qml
        #fileObserver.dirChangetSig.connect(controller.anotherInstanceEvent)


def setupSingleton(args):
    needSingleton = QtCore.QSettings().value("Preferences/singleton", False, type=bool)
    if int(needSingleton):
        me = SingleInstance()
        dirname = os.path.dirname(sys.argv[0])
        tempFileName = dirname + "/qtodo.tmp"
        if me.initialized is True:
            if os.path.isfile(tempFileName):
                os.remove(tempFileName)
        else:
            f = open(tempFileName, 'w')
            f.flush()
            f.close()
            sys.exit(-1)


def run():
    # First set some application settings for QSettings
    QtCore.QCoreApplication.setOrganizationName("QTodoTxt")
    QtCore.QCoreApplication.setApplicationName("QTodoTxt2")
    # Now set up our application and start
    app = QtWidgets.QApplication(sys.argv)
    # it is said, that this is lighter:
    # (without qwidgets, as we probably don't need them anymore, when transition to qml is done)
    # app = QtGui.QGuiApplication(sys.argv)

    name = QtCore.QLocale.system().name()
    translator = QtCore.QTranslator()
    if translator.load(str(name) + ".qm", "..//i18n"):
        app.installTranslator(translator)

    args = _parseArgs()

    setupSingleton(args)

    _setupLogging(args.loglevel)

    engine = QQmlApplicationEngine(parent=app)
    controller = MainController(args)
    engine.rootContext().setContextProperty("mainController", controller)
    path = os.path.dirname(__file__)
    engine.addImportPath(path + '/qml/')
    engine.load(path + '/qml/QTodoTxt.qml')

    setupAnotherInstanceEvent(controller)

    controller.start()
    app.exec_()
    sys.exit()


if __name__ == "__main__":
    run()
