
# MODULE := othername
# MODULE_TYPE := app

# папки для поиска заголовочных файлов
MODULE_HEADER_DIRS := include
# MODULE_MOC := yes

# заголовочные файлы для предкомпиляции
MODULE_GCHS := include/QtCore/QtCore include/QtGui/QtGui
MODULE_GCHS += include/QtSvg/QtSvg   include/QtWidgets/QtWidgets

# папки для поиска динамических библиотек
MODULE_LIB_DIRS := lib

# динамические библиотеки от которых зависит `app` или `lib`
MODULE_LIBS := Qt5Core Qt5Gui Qt5Svg Qt5Widgets

# ресурсы Qt
MODULE_QTRES := resources/resources.qrc
MODULE_QTSUBSYSTEM := console
# MODULE_QTSUBSYSTEM := windows

# статические библиотеки от которых зависит `app` или `lib`
# MODULE_STATIC_LIBS :=

MODULE_SRCS := $(wildcard src/[!_]*.cpp)
