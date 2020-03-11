# минимальный вариант файла `rules.mk`:
# -----------------------------------------------------------------------------
# папки для поиска заголовочных файлов
# MODULE_HEADER_DIRS := include
# папки для поиска динамических библиотек
# MODULE_LIB_DIRS := lib
# MODULE_SRCS := $(wildcard src/[!_]*.cpp)
# -----------------------------------------------------------------------------

# если не задано имя модуля, то оно совпадает с именем директории
MODULE := $(or $(MODULE),$(lastword $(subst /, ,$(CURDIR))))
MODULE_TYPE ?= app

# нужно ли запустить модуль после сборки (только для MODULE_TYPE == app)
MODULE_EXECUTE := $(if $(filter $(MODULE_TYPE),app),$(if $(filter $(MODULE_EXECUTE),yes),yes,no),no)

# приложение
ifeq ($(MODULE_TYPE),app)
	MODULE_SUFFIX := $(if $(filter Windows_NT,$(OS)),.exe)
endif

# динамическая библиотека
ifeq ($(MODULE_TYPE),lib)
	MODULE := $(if $(filter Windows_NT,$(OS)),$(MODULE),lib$(MODULE))
	MODULE_SUFFIX := $(if $(filter Windows_NT,$(OS)),.dll,.so)
endif

# статичная библиотека
ifeq ($(MODULE_TYPE),static)
	MODULE := lib$(MODULE)
	MODULE_SUFFIX := .a
endif

# добавление define DEBUG для отладочных сборок
MODULE_DEFINES += $(if $(filter true,$(call TOBOOL,$(RELEASE))),,DEBUG)

# MODULE_OBJS := $(patsubst %.cpp,%.o,$(call GET_FILENAME,$(MODULE_SRCS)))
MODULE_OBJS := $(patsubst %.cpp,%.o,$(call SLASH_TO_UNDERSCOPE,$(MODULE_SRCS)))
MODULE_OBJS := $(patsubst %.c,%.o,$(call SLASH_TO_UNDERSCOPE,$(MODULE_OBJS)))
MODULE_OBJS := $(patsubst %.s,%.o,$(call SLASH_TO_UNDERSCOPE,$(MODULE_OBJS)))
MODULE_OBJS += $(patsubst %.qrc,%.o,$(call SLASH_TO_UNDERSCOPE,$(MODULE_QTRES)))

MODULE_PCH_OBJS := $(if $(filter true,$(call TOBOOL,$(USE_CLANG))),\
$(addsuffix .pch,$(basename $(notdir $(MODULE_PCHS)))))
# MODULE_PCH_OBJS := $(addsuffix .pch,$(basename $(notdir $(MODULE_PCHS))))

# список переменных
# -----------------------------------------------------------------------------
# MODULE : module name (required)
# MODULE_SRCS : list of source files, local path (required)
# MODULE_DEPS : other modules that this one depends on
# MODULE_HEADER_DEPS : other headers that this one depends on, in addition to MODULE_DEPS
# MODULE_DEFINES : #defines local to this module
# MODULE_OPTFLAGS : OPTFLAGS local to this module
# MODULE_COMPILEFLAGS : COMPILEFLAGS local to this module
# MODULE_CFLAGS : CFLAGS local to this module
# MODULE_CPPFLAGS : CPPFLAGS local to this module
# MODULE_ASMFLAGS : ASMFLAGS local to this module
# MODULE_SRCDEPS : extra dependencies that all of this module's files depend on
# MODULE_EXTRA_OBJS : extra .o files that should be linked with the module
# MODULE_TYPE : "app" for userspace executables
#               "lib" for userspace library,
#               "static" for Zircon driver
#               "hostapp" for a host tool,
#               "hosttest" for a host test,
#               "hostlib" for a host library,
#               "" for kernel,
# MODULE_LIBS : shared libraries for a userapp or userlib to depend on
# MODULE_STATIC_LIBS : static libraries for a userapp or userlib to depend on
# MODULE_FIDL_LIBS : fidl libraries for a userapp or userlib to depend on the C bindings of
# MODULE_FIDL_LIBRARY : the name of the FIDL library being built (for fidl modules)
# MODULE_BANJO_LIBS : banjo libraries for a userapp or userlib to depend on the C bindings of
# MODULE_BANJO_LIBRARY : the name of the BANJO library being built (for banjo modules)
# MODULE_FIRMWARE : files under prebuilt/downloads/firmware/ to be installed under /boot/driver/firmware/
# MODULE_SO_NAME : linkage name for the shared library
# MODULE_HOST_LIBS: static libraries for a hostapp or hostlib to depend on
# MODULE_HOST_SYSLIBS: system libraries for a hostapp or hostlib to depend on
# MODULE_GROUP: tag for manifest file entry
# MODULE_PACKAGE: package type (src, fidl, banjo, so, a) for module to export to SDK
# MODULE_PACKAGE_SRCS: override automated package source file selection, or the special
#                      value "none" for header-only libraries
# MODULE_PACKAGE_INCS: override automated package include file selection

