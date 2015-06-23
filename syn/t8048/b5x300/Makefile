##############################################################################
#
# Generic Makefile for ISE projects
#
# $Id: Makefile 295 2009-04-01 19:32:48Z arniml $
#
# Execute with 'make <target>', where target is one of
#   ise           : build ISE project from
#                   - files in compile_list
#                   - project settings in timing.ucf and <board>.ucf
#                   - project settings applied in gen_ise_project.tcl
#   compile       : compile ISE project by means of tcl script
#                   compile_project.tcl
#   <blank> | all : run through all targets above
#
##############################################################################

export MODULE := t8048

export COMPILE_LIST := compile_list
SOURCE_FILES := $(shell cat $(COMPILE_LIST))
export BLD := bld

.PHONY: all
all: $(BLD)/$(MODULE).bit

.PHONY: ise
ise: $(BLD)/$(MODULE).ise

.PHONY: compile
compile: $(BLD)/$(MODULE).bit

$(BLD)/$(MODULE).ise: $(COMPILE_LIST) *.ucf gen_ise_project.tcl
	xtclsh gen_ise_project.tcl

$(BLD)/$(MODULE).bit: $(SOURCE_FILES) $(BLD)/$(MODULE).ise compile_project.tcl
	xtclsh compile_project.tcl
	touch $@

.PHONY: clean
clean:
	rm -rf *~ bld
