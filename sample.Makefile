
# корневая папка для сбора проекта
MAKEROOT = .
# BUILDDIR = .build 13
# RELEASE = yes

export MAKEROOT
export BUILDDIR
export RELEASE

#all::
#	$(info $(subst $(SPACE),_,$(BUILDDIR)))

all::
	@$(MAKE) -C $(MAKEROOT) --no-print-directory -f make/engine.mk
#	@$(MAKE) -C Cursic2 --no-print-directory -f make/engine.mk


#.PHONY: all $(MAKECMDGOALS)
#$(MAKECMDGOALS) all:
#	$(MAKE) -C $(MAKEROOT) --no-print-directory -f make/engine.mk $(MAKECMDGOALS)

