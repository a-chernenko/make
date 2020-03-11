
EMPTY :=
COMMA :=,
define BR
$(1)

endef

TOBOOL = $(if $(filter-out 0 false no,$1),true,false)
ARCH = $(if $(filter AMD64,$(PROCESSOR_ARCHITECTURE)),x86_64,x86)
LIB_TO_NAME = $(if $(filter Windows_NT,$(OS)),$(1).dll,lib$(1).so*)

# выбор команды для создания директории
MKDIR = $(if $(or $(filter Windows_NT,$(OS)),$(CROSS)),\
cmd.exe /c IF not exist $(subst /,\\,$(1)) \(mkdir $(subst /,\\,$(1))\),\
if [ ! -d $(1) ]; then mkdir -p $(1); fi)

# выбор команды для копирования
COPY = $(if $(filter Windows_NT,$(OS)),\
cmd.exe /c copy $(subst /,\\,$(1)) $(subst /,\\,$(2)),\
cp $(1) $(2))

# cmd.exe /c "IF not exist obj (mkdir obj)"
# cmd.exe /c "del /q $(subst /,\,$(OBJS))"
# cmd.exe /c "del /q $(subst /,\,libGLFW.a libGLFW.dll)"
# rm -rf $(BUILDDIR)

# замена всех пробелов на символ `_`
# $(call SPACE_DEL,123 456) --> 123_456
SPACE_DEL = $(subst $(EMPTY) $(EMPTY),_,$(1))

GET_FILENAME = $(foreach val,$(1),$(lastword $(subst /, ,$(val))))

# записывает в переменную уникальные имена папок
# $(call GET_UNIQUE_DIRS,dir1 dir2 dir1 dir3,RESULT_DIRS)
GET_UNIQUE_DIRS = $(foreach val,$(1),$(if $(filter $(val),$($(2))),,$(eval $(2) += $(val))))

# замена символа `/` на `_`
SLASH_TO_UNDERSCOPE = $(foreach val,$(1),$(subst /,_,$(val)))
UNDERSCOPE_TO_SLASH = $(foreach val,$(1),$(subst _,/,$(val)))
