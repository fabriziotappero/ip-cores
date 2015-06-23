#Konrad Eisele<eiselekd@web.de>,2003

all: $(cmd)

include $(obj)/Makefile
include build/Makefile.defs

# Select host/target compilation
# ---------------------------------------------------------------------------
CURGCC = $(GCC)
CURLD = $(LD)
CURAR = $(AR)
CURCFLAGS = $(c_flags)
CURLDFLAGS = $(ld_flags)

# Single targets
# ---------------------------------------------------------------------------


  cmd_as_s_S = $(CPP) $(a_flags)   -o $@ $< 
q_cmd_as_s_S = CPP $@
%.s: %.S FORCE
	$(call if_changed_dep,as_s_S)

  cmd_c_to_o = $(CURGCC) $(CURCFLAGS) -c -o $@ $<
q_cmd_c_to_o = GCC $@
%.o: %.c FORCE
	$(call if_changed_dep,c_to_o)

  cmd_as_o_S = $(CC) $(a_flags) -c -o $@ $< 
q_cmd_as_o_S = AS $@
%.o: %.S FORCE
	$(call if_changed_dep,as_o_S)

%.tab.c: %.y
	bison -t -d -v -b $* -p $(notdir $*)_ $<

# adjust to sub-directory 
# ---------------------------------------------------------------------------
$(target)_files         := $(addprefix $(obj)/,$($(target)_files))
$(target)_target        := $(addprefix $(obj)/,$($(target)_target))
$(target)_subdirs	:= $(addprefix $(obj)/,$($(target)_subdirs))

# cmds to use 
# ---------------------------------------------------------------------------
cmd_ld = $(CURLD) -o $@ $(filter-out FORCE,$^) $(CURLDFLAGS) $(EXTRA_LDFLAGS) 	        
cmd_ar = $(CURAR) -r -o $@  $(filter-out FORCE,$^) 
#$(CURAR) r $@  $(filter-out FORCE,$^) 
#

ifeq ($(strip $(suffix $($(target)_target))),.a)
	docmd = ar
else
	docmd = ld
endif

dobuild: $($(target)_target) $($(target)_predeps)

$($(target)_target): $($(target)_files)  FORCE
	$(call if_changed,$(docmd)) 

$(addsuffix /build.a,$($(target)_subdirs)): FORCE
	for i in $($(target)_subdirs); do \
		$(MAKE) -f build/Makefile.switch obj=$$i cmd=dobuild || exit 1; \
	done

FORCE:

# Read all saved command lines and dependencies for the $(alltargets) we
# may be building above, using $(if_changed{,_dep}). As an
# optimization, we don't need to read them if the target does not
# exist, we will rebuild anyway in that case.
# ---------------------------------------------------------------------------
alltargets 		:= $($(target)_files) $($(target)_target)
alltargets 		:= $(wildcard $(sort $(alltargets)))
cmd_files 		:= $(wildcard $(foreach f,$(alltargets),$(dir $(f)).$(notdir $(f)).cmd))
ifneq ($(cmd_files),)
  include $(cmd_files)
endif

-include $(obj)/Makefile.post





