
Rewrite of GUI code of QTodoTxt using qml. 

[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/QTodoTxt/QTodoTxt2/badges/quality-score.png?b=qml)](https://scrutinizer-ci.com/g/QTodoTxt/QTodoTxt2/?branch=qml)
[![Build Status](https://travis-ci.org/QTodoTxt/QTodoTxt2.svg?branch=qml)](https://travis-ci.org/QTodoTxt/QTodoTxt2)


![screenshot from 2017-05-30 16-55-20](https://cloud.githubusercontent.com/assets/2564046/26589896/7cc386b6-4559-11e7-96ef-18ec2dc38a10.png)

FAQ:

Why a rewrite? 

* To finally have a clean split between GUI code and logic. 

but why? 

* because it was fun to do. Now we get a better score at scutinizer! 
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/QTodoTxt/QTodoTxt2/badges/quality-score.png?b=qml)](https://scrutinizer-ci.com/g/QTodoTxt/QTodoTxt2/?branch=qml)


Main differences to QTodoTxt 1:
* Much cleaner code, simpler packaging
* calendar widget for due: and t:
* support of hidden tasks: h:1
* Remove support for some legacy options ans technologies like systray

Installation

There are many ways to install and run QTodoTxt2. 

On ubuntu 16.04 and up:

1. sudo apt-get install python3-pyqt5 qtdeclarative5-models-plugin python3-pyqt5.qtquick qml-module-qt-labs-settings qml-module-qtquick-controls qml-module-qtquick-dialogs

2. Download QTodoTxt2 source and unpack to a location of your choice.

3. Navigate to the 'bin' subdirectory of QTodoTxt2 and run the 'qtodotxt.py' file.

4. In QToDoTxt2 open/select you todo file and you should be good to go.

On Windows:

1. Download the file: WinPython 3.5.3.1Qt5-64bit (*) or 32 bit version at (http://winpython.github.io/)

2. I have found it best to install this off of your root (i.e.: c:\winpython). not in program files or apps (doesn't seem to work for me).

3. Register it by running winpython control panel.exe. select 'advanced' then 'register distribution'

4. Download QTodoTxt2 source and unzip to a location of your choice.

5. Navigate to the 'bin' subdirectory of QTodoTxt2 and run the 'qtodotxt.pyw' file.
6. In QToDoTxt2 open/select you todo file and you should be good to go.
