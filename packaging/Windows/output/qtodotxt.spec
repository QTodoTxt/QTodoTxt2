# -*- mode: python -*-

block_cipher = None


a = Analysis(['..\\..\\..\\bin\\qtodotxt'],
             pathex=['C:\\Windows\\System32\\downlevel\\', '.\\..\\..\\..\\', 'C:\\Qt\\5.12.0\\msvc2017_64\\bin', 'C:\\Program Files\\python_installed\\Lib', 'D:\\Computers\\Software_development\\git\\QTodoTxt2\\packaging\\Windows\\output'],
             binaries=[],
             datas=[('.\\..\\..\\..\\qtodotxt2\\qml', '.\\qtodotxt2\\qml')],
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          [],
          exclude_binaries=True,
          name='qtodotxt',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          console=False , icon='..\\..\\..\\packaging\\Windows\\qTodo.ico')
coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               a.datas,
               strip=False,
               upx=True,
               name='qtodotxt')
