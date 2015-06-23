###############################################################################
# Requires: GNU make and basic GNU utilities
#           Xilinx ISE
#
# Asbjørn Djupdal 2003, 2008
###############################################################################

# IMPORTANT: ucf-file must be named $(PROJECT_NAME).ucf

###############################################################################
# the following variables must be set according to your project
###############################################################################

ISE_DIR = /opt/Xilinx/11.1/ISE/bin/lin

# select a name for your project (used as basename for most generated files)
PROJECT_NAME = leval2

# list VHDL sourcefiles (separated with spaces) in correct synthesis order
#SOURCE_FILES = package.vhd bidirbus.vhd synchronizer.vhd alu.vhd addr_decoder.vhd cache.vhdl control.vhd inst_mem.vhd preload_dualport_mem.vhd singleport_mem.vhd if.vhd id.vhd ex.vhd mem.vhd whisk.vhd

SOURCE_FILES = pipelineregs.vhd leval2_constants.vhd forward.vhd hazard.vhd rrwmem.vhd rwmem.vhd alu.vhd control.vhd addr_decoder.vhd bidirbus.vhd toplevel.vhd leval2.vhd

# name of top level entity
TOP_LEVEL = toplevel

# target device
DEVICE = XC3S500E-5-pq208

# synthesis (xst) options
SYNTH_OPTS = -opt_mode Speed -opt_level 1 -register_duplication no \
	-hierarchy_separator / -keep_hierarchy yes -uc toplevel.xcf

# options for bitfile generation
BITGEN_OPTS = -g DriveDone:No -g StartUpClk:JTAGCLK \
		-g DONE_cycle:4 -g GTS_cycle:5 -g DonePipe:No \
		-g GWE_cycle:6 -g LCK_cycle:NoWait -g Security:NONE 

###############################################################################
# rules, no need to change anything below this line
###############################################################################

# default rule: create both bitfile and files for timing simulation
.PHONY : default
default : $(PROJECT_NAME).bit time_sim.vhd 

# create temporary project and script files for XST
$(PROJECT_NAME).xst : $(SOURCE_FILES) 
	exec /opt/Xilinx/11.1/ISE/settings32.sh
	echo $(SOURCE_FILES) | xargs -n 1 > $(PROJECT_NAME).prj 
	echo -n "run -ifn $(PROJECT_NAME).prj -ofn $(PROJECT_NAME).ngc " > $@
	echo -n "-ofmt NGC -p $(DEVICE) -top $(TOP_LEVEL) -ifmt VHDL " >> $@
	echo "$(SYNTH_OPTS)" >> $@

# synthesis with XST
$(PROJECT_NAME).ngc : $(PROJECT_NAME).xst
	$(ISE_DIR)/xst -ifn $<

# implementation
$(PROJECT_NAME).ncd : $(PROJECT_NAME).ngc
	$(ISE_DIR)/xflow -p $(DEVICE) -implement high_effort.opt $<

# bitfile generation
$(PROJECT_NAME).bit : $(PROJECT_NAME).ncd $(PROJECT_NAME).pcf
	$(ISE_DIR)/bitgen -l -w -m -intstyle xflow $(BITGEN_OPTS) $<

# generate files for timing simulation
time_sim.vhd : $(PROJECT_NAME).ncd $(PROJECT_NAME).pcf
	$(ISE_DIR)/xflow -p $(DEVICE) -tsim modelsim_vhdl.opt $<

.PHONY : clean
clean :
	rm -rf *.opt *.flw *.bgn *.bit *.bld *.drc *.ll *.msk *.ncd *.ngc \
		*.ngd *.pad *.par *.pcf *.prj *.rbt *.twr *.twx *.xpi *_map* \
		*_pad* *_timing* *_xst* *.lst *.nlf *.sdf xflow* xst *.xst \
		*.srp .prj .srp .xst

