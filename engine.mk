# Список всех define'ов: gcc -dM -E - < nul > defines.txt
# Список всех целей: make -qp > targets.txt
# https://makefiletutorial.com/

# $(error ERROR)
# $(warning WARNING)
# $(info INFO)

include $(MAKEROOT)/make/macros.mk
include rules.mk
include $(MAKEROOT)/make/module.mk

BUILDDIR_SUFFIX = $(if $(filter true,$(call TOBOOL,$(RELEASE))),release,debug)
BUILDDIR := $(MAKEROOT)/$(call SPACE_DEL,$(or $(BUILDDIR),.build))
RESULTDIR := $(BUILDDIR)
BUILDDIR := $(BUILDDIR)/$(MODULE)-$(BUILDDIR_SUFFIX)
MODULE_OBJS := $(addprefix $(BUILDDIR)/,$(MODULE_OBJS))
MODULE_LIB_DIRS := $(RESULTDIR) $(MODULE_LIB_DIRS)
MODULE_PCH_OBJS := $(addprefix $(BUILDDIR)/,$(MODULE_PCH_OBJS))

# Выбор компилятора
# -----------------------------------------------------------------------------
USE_CLANG ?= no
AS := $(if $(filter true,$(call TOBOOL,$(USE_CLANG))),clang,$(CROSS)gcc)
CC := $(if $(filter true,$(call TOBOOL,$(USE_CLANG))),clang -std=c11,$(CROSS)gcc -std=c11)
CXX := $(if $(filter true,$(call TOBOOL,$(USE_CLANG))),clang++ -std=c++17,$(CROSS)g++ -std=c++17)

# GCC && LD флаги
# -----------------------------------------------------------------------------
CXXFLAGS := -Wall -Wextra $(MODULE_FLAGS)
#CXXFLAGS += $(addprefix -isystem , $(MODULE_SYSHEADER_DEPS))
CXXFLAGS += $(addprefix -I, $(MODULE_HEADER_DIRS))
CXXFLAGS += $(addprefix -D, $(MODULE_DEFINES))
CXXFLAGS += $(if $(filter false,$(call TOBOOL,$(USE_CLANG))),-fpic)

PCHFLAGS := $(if $(filter true,$(call TOBOOL,$(USE_CLANG))),\
$(foreach pch,$(MODULE_PCHS),-include-pch $(BUILDDIR)/$(basename $(notdir $(pch))).pch))
# PCHFLAGS := $(foreach pch,$(MODULE_PCHS),-include-pch $(BUILDDIR)/$(basename $(notdir $(pch))).pch)

LDFLAGS := $(if $(filter lib,$(MODULE_TYPE)),-shared)
LDFLAGS += $(addprefix -L, $(MODULE_LIB_DIRS))
LDFLAGS += $(addprefix -l, $(MODULE_LIBS))
LDFLAGS += $(if $(MODULE_QTSUBSYSTEM),-Wl$(COMMA)-subsystem$(COMMA)$(MODULE_QTSUBSYSTEM))
LDFLAGS += $(MODULE_LDFLAGS)

LDFLAGS += $(if $(filter Windows_NT,$(OS)),$(if $(filter true,$(call TOBOOL,$(USE_CLANG))),\
-static-libgcc,-static-libgcc -Wl$(COMMA)-static -lpthread))
# LDFLAGS += -static-libgcc

# Release || Debug
# -----------------------------------------------------------------------------
ifeq ($(call TOBOOL,$(RELEASE)), true)
	CXXFLAGS += -O2
	LDFLAGS  += -s
else
	CXXFLAGS += -O0 -g
endif

# Цели
# -----------------------------------------------------------------------------
#.PHONY: all clean
#all::
#	$(info $(RESULTDIR))

all:: $(BUILDDIR) $(MODULE_PCH_OBJS) $(RESULTDIR)/$(MODULE)$(MODULE_SUFFIX)
	$(if $(filter true,$(call TOBOOL,$(MODULE_EXECUTE))),$(RESULTDIR)/$(MODULE)$(MODULE_SUFFIX))

#$(if $(filter $(MODULE_GCHS),),$(BUILDDIR)/headers.gch) \

$(BUILDDIR):
	$(call MKDIR,$@)
#	$(foreach lib,$(MODULE_HOST_SYSLIBS),\
#		$(call COPY,$(MODULE_HOST_SYSLIBS_DIR)/$(call LIB_TO_NAME,$(lib)),$(RESULTDIR))$(call BR))

# предварительная компиляция избранных заголовков
$(BUILDDIR)/%.pch:
	$(CXX) -x c++-header $(CXXFLAGS) -o $@ -c $(filter %$(basename $(notdir $@)),$(MODULE_PCHS))

$(BUILDDIR)/%.gch:
	$(CXX) -x c++-header $(CXXFLAGS) -o $@ -c $(filter %$(basename $(notdir $@)),$(MODULE_PCHS))

# линковка (статическая или динамическая)
$(RESULTDIR)/$(MODULE)$(MODULE_SUFFIX): $(MODULE_OBJS)
	$(if $(filter $(MODULE_TYPE),static),ar cr $@ $^,$(CXX) -o $@ $^ $(LDFLAGS))

-include $(MODULE_OBJS:.o=.d)

# цели для всех `.cpp` исходников
TARGET_CPP = $$(BUILDDIR)/$(call SLASH_TO_UNDERSCOPE,$(1:.cpp=.o)): $(1) ; $(CXX) $(CXXFLAGS) $(PCHFLAGS) -MMD -o $$@ -c $$<
$(foreach src,$(filter %.cpp,$(MODULE_SRCS)),$(eval $(call TARGET_CPP,$(src))))

# цели для всех `.c` исходников
TARGET_C = $$(BUILDDIR)/$(call SLASH_TO_UNDERSCOPE,$(1:.c=.o)): $(1) ; $(CC) $(CXXFLAGS) $(PCHFLAGS) -MMD -o $$@ -c $$<
$(foreach src,$(filter %.c,$(MODULE_SRCS)),$(eval $(call TARGET_C,$(src))))

# цели для всех `.s` исходников
TARGET_ASM = $$(BUILDDIR)/$(call SLASH_TO_UNDERSCOPE,$(1:.s=.o)): $(1) ; $(AS) -o $$@ -c $$<
$(foreach src,$(filter %.s,$(MODULE_SRCS)),$(eval $(call TARGET_ASM,$(src))))

# компиляция Qt ресурсов
$(BUILDDIR)/$(call SLASH_TO_UNDERSCOPE,$(MODULE_QTRES:.qrc=.o)): $(MODULE_QTRES)
	rcc.exe -compress 6 -threshold 0 $< -o $(@:.o=.cpp)
	$(CXX) $(CXXFLAGS) -o $@ -c $(@:.o=.cpp)


clean::
	rm -rf $(BUILDDIR)
	rm -f $(RESULTDIR)/$(MODULE)$(MODULE_SUFFIX)

#%.moc.cpp: %.hpp
#	moc -o $@ $<


# очистка
# cmd.exe /c "IF not exist obj (mkdir obj)"
# cmd.exe /c "del /q $(subst /,\,$(OBJS))"
# cmd.exe /c "del /q $(subst /,\,libGLFW.a libGLFW.dll)"


# Запасник :-)
# -----------------------------------------------------------------------------
# $(strip string)
# VPATH = src

# clang++ -std=c++17 -x c++-header -Iinclude -c include/QtCore/QtCore -o QtCore.pch
# clang++ -std=c++17 -g -Iinclude -include QtCore -c src/main.cpp
# clang++ -Llib -lQt5Core -static-libgcc main.o

#@echo.Extract  : assembly list file  : from bin/led.elf
#@%TOOL_PATH%\%TOOL_PREFIX%-objdump -h -S bin/led.elf > bin/led.lss

#@echo.Extract  : size information    : from bin/led.elf
#@%TOOL_PATH%\%TOOL_PREFIX%-size -A -t bin/led.elf > bin\led_size.txt

#@echo.Extract  : name information    : from bin/led.elf
#@%TOOL_PATH%\%TOOL_PREFIX%-nm --numeric-sort --print-size bin/led.elf > bin\led_nm.txt

#@echo.Extract  : demangled names     : from bin/led.elf
#@%TOOL_PATH%\%TOOL_PREFIX%-nm --numeric-sort --print-size bin/led.elf | %TOOL_PATH%\%TOOL_PREFIX%-c++filt > bin\led_cppfilt.txt
