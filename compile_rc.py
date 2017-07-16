#!/usr/bin/env python

import os


if __name__ == "__main__":
    print("Compiling for PyQt5: res.qrc -> qTodoTxt_style_rc.py")
    os.system("pyrcc5 ./qtodotxt2/qml/Theme/res.qrc -o ./qtodotxt2/qTodoTxt_style_rc.py")
