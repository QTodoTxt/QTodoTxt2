# Build Windows package
Building an executable is done by [pyinstaller](https://www.pyinstaller.org/ "pyinstaller").

## Prerequisites

The following software is needed for building the package for windows:
* Windows 10 build: 1809
* Python installation in version 3.7.2 (64 bit)
* Qt in Version 5.12

The python installation needs the follwing packages to be installed using pip:
* PyQt5
* pyinstaller
* sip

Qt needs the follwing items to be installed:
* MSVC 2017 (64 bit)

## Starting the package build

Open powershell with administrative rights in folder

	QTodoTxt2\packaging\Windows\output

and call (replace the missing paths before):

	& "C:\<PATH TO YOUR PYTHON>\python.exe" -m PyInstaller --paths C:\Windows\System32\downlevel\  --paths "<PATH TO YOUR GIT REPOSITORY LOCATION>\QTodoTxt2" --paths "<PATH TO YOUR QT INSTALLATION FOLDER>\Qt\5.12.0\msvc2017_64\bin" --paths "<PATH TO YOUR PYTHON INSTALLATION>\Lib" --add-data '<PATH TO YOUR GIT REPOSITORY LOCATION>\QTodoTxt2\qtodotxt2\qml;.\qtodotxt2\qml' "<PATH TO YOUR GIT REPOSITORY LOCATION>\QTodoTxt2\bin\qtodotxt"

The current call on the developers machine looks like:

	 & "C:\Program Files\python_installed\python.exe" -m PyInstaller --paths "C:\Windows\System32\downlevel\" --paths .\..\..\..\  --paths "C:\Qt\5.12.0\msvc2017_64\bin" --paths "C:\Program Files\python_installed\Lib" --add-data '.\..\..\..\qtodotxt2\qml;.\qtodotxt2\qml' --icon ".\..\..\..\packaging\Windows\qTodo.ico" --noconsole ".\..\..\..\bin\qtodotxt"