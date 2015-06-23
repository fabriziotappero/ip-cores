# 

export ROOT_DIR = ../..

MODEL_TECH ?= /cygdrive/c/altera/91/modelsim_ase/win32aloem
PATH := ${MODEL_TECH}:${PATH}


VLIB = vlib 
VLOG = vlog 
VMAKE = vmake 

# WORK_LIBRARY_FILES += $(shell grep [\.]v[[:space:]]*$$ $(WORK_LIBRARY)_files.txt | tr '\n' ' ' )

WORK_LIBRARY += sim


ALL_MK_FILES = $(foreach mk, $(WORK_LIBRARY), ./$(mk)/$(mk).mk)
ALL_REFRESH  = $(foreach refresh, $(WORK_LIBRARY), $(refresh)_refresh )
# ALL_DEBUG    = $(foreach debug, $(WORK_LIBRARY), $(debug)_debug )
# ALL_INFO     = $(foreach info, $(WORK_LIBRARY), ./$(info)/_info )


define build_unit
$(1): $(1)_files.txt
	@echo "-#- initial build of $$@ library."
	$(VLIB) $$@
	$(VLOG) -O0 -work $$@ -f $$@_files.txt
	@echo "-#- "

./$(1)/$(1).mk: $(1)_files.txt
	@echo "-#- generating unit make file for $$*."
	$(VMAKE) $(1) > $$@
	@echo "-#- "

$(1)_refresh: 
	@echo "-#- refreshing unit $(1)."
	$$(MAKE) -f ./$(1)/$(1).mk
	@echo "-#- "

# $(1)_debug: 
# 	@echo "-d- "
# 	@echo "-d- $$@ -  $$* - $$% - $$<  "
# 	@echo "-d- $(shell grep [\.]v[[:space:]]*$$ $(1)_files.txt | tr '\n' ' ' ) "
# 	@echo "-d- "

endef


.PHONY: all clean 

all: $(WORK_LIBRARY) $(ALL_MK_FILES) $(ALL_REFRESH) 
# all: debug
# all: $(WORK_LIBRARY) $(ALL_MK_FILES) $(ALL_DEBUG) 

$(foreach unit,$(WORK_LIBRARY),$(eval $(call build_unit,$(unit))))

clean:
	-rm -Rf $(WORK_LIBRARY)

# debug: 
# 	@echo "-d- $@ -  $* - $% - $<  "
# 	@echo "-d- $(PATH)  "


