from setuptools import setup, find_packages

import sys


setup(name="qtodotxt2", 
      version="2.0.0a6",
      description="Cross Platform todo.txt GUI",
      author="QTT Development Team",
      author_email="qtodotxt@googlegroups.com",
      url='https://github.com/QTodoTxt/QTodoTxt2',
      #packages=find_packages(where='.', include=["*.py", "*.qrc", "*.qml"], exclude=["tests"]),
      packages=find_packages(),
      #packages=['qtodotxt', 'qtodotxt/lib'],
      package_data={
          'qtodotxt2':['qml/*.qml', 'qml/Theme/*.qml', 'qml/Theme/qmldir']
          },
      #include_package_data=True,
      provides=["qtodotxt2"],
      install_requires=["python-dateutil"],
      license="GNU General Public License v3 or later",
      classifiers=["Environment :: X11 Applications :: Qt",
                   "Programming Language :: Python :: 3",
                   "Intended Audience :: End Users/Desktop",
                   "Operating System :: OS Independent",
                   "License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)"
                   ],
      entry_points={'gui_scripts': 
                    [
                        'qtodotxt2 = qtodotxt2.app:run'
                    ]
                    }
      )

