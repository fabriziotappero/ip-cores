#=======================================================================
# 6.375 Makefile for enc-par
#-----------------------------------------------------------------------
# $Id: Makefile,v 1.1 2008-06-26 17:58:43 jamey.hicks Exp $
#
# This makefile will use Cadence Encounter to place and route
# a gate-level verilog netlist.
#

default : all

basedir  = ../..

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

vsrcs = ../dc/current/synthesized.v

# Specify what the toplevel verilog module is

toplevel = mkH264

# Specify the floorplan if it exists. 

#floorplan = ../enc-fp/current/floorplan.fp

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

build_suffix   := $(shell date +%Y-%m-%d_%H-%M)
build_dir      := build-$(build_suffix)
curr_build_dir := current
curr_build_dir_tstamp := current/timestamp.txt
par_verilog    := $(curr_build_dir)/par.v
vsrc_unique    := synthesized_unique.v

par_conf       := par.conf
par_tcl        := par.tcl
par_sdc        := par.sdc
scripts        := $(par_conf) $(par_tcl) $(par_sdc)
makegen_tcl    := make_generated_vars.tcl

libdir = $(MIT6375_HOME)/libs/tsl180/tsl18fs120
par_vars = \
	set VERILOG_SRC      { $(vsrc_unique) }; \
	set VERILOG_TOPLEVEL $(toplevel); \
	set FLOORPLAN        "$(addprefix ../, $(floorplan))"; \
	set TIMELIBS_MAX     { $(libdir)/lib/tsl18fs120_max.lib }; \
	set TIMELIBS_MIN     { $(libdir)/lib/tsl18fs120_min.lib }; \
	set TIMELIBS_TYP     { $(libdir)/lib/tsl18fs120_typ.lib }; \
	set LEF_FILES        { $(libdir)/lef/tsl18_6lm.lef $(libdir)/lef/tsl18fs120.lef }; \

define new-build-dir-cmds
	mkdir $(build_dir)
	rm -f $(curr_build_dir)
	ln -s $(build_dir) $(curr_build_dir)
	cp $(scripts) $(curr_build_dir)
	echo '$(par_vars)' > $(curr_build_dir)/$(makegen_tcl)
endef

new-build-dir :
	$(new-build-dir-cmds)

$(par_verilog) : $(vsrcs) $(floorplan) $(scripts) 
	$(new-build-dir-cmds)
	cd $(curr_build_dir); \
	uniquifyNetlist -top $(toplevel) $(vsrc_unique) $(addprefix ../, $(vsrcs)); \
	encounter -nowin -init $(par_tcl) | tee enc.log; \
	cd ..

par : $(par_verilog)

junk += 

.PHONY : par new-build-dir

#--------------------------------------------------------------------
# Default make target
#--------------------------------------------------------------------

all : par

#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

clean :
	rm -rf build-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9] \
	       current $(junk) *~ \#*
