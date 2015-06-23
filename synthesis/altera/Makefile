MODULE=RS_dec
###################################################################
# Project Configuration: 
# 
# Specify the name of the design (project), the Quartus II Settings
# File (.qsf), and the list of source files used.
###################################################################

PROJECT ?= $(MODULE)
DEPS ?=
SOURCE_FILES ?= $(wildcard ../../rtl/*.v)

ASSIGNMENT_FILES = $(PROJECT).qpf $(PROJECT).qsf 

###################################################################
# Main Targets
#
# all: build everything
# clean: remove output files and database
###################################################################

all: smart.log $(PROJECT).asm.rpt $(PROJECT).sta.rpt $(PROJECT).eda.rpt

clean:
	rm -rf *.chg smart.log *.htm *.eqn *.pin *.sof *.pof db *.summary *.smsg *.qdf simulation dse incremental_db

all-clean: clean
	rm -rf *.rpt *.done *~

map: smart.log $(PROJECT).map.rpt
fit: smart.log $(PROJECT).fit.rpt
asm: smart.log $(PROJECT).asm.rpt
tan: smart.log $(PROJECT).tan.rpt
sta: smart.log $(PROJECT).sta.rpt
eda: smart.log $(PROJECT).eda.rpt
dse: $(PROJECT).dse.rpt
smart: smart.log

###################################################################
# Executable Configuration
###################################################################

#MAP_ARGS = --family="StratixII"
#FIT_ARGS = --part=EP2S180F1508C3
FIT_ARGS =
ASM_ARGS =
TAN_ARGS =
STA_ARGS =
DSE_ARGS =  -exploration-space "Physical Synthesis with Retiming Space"
###################################################################
# Target implementations
###################################################################

STAMP = echo done >

$(PROJECT).map.rpt: map.chg $(SOURCE_FILES) 
	quartus_map $(MAP_ARGS) $(PROJECT)
	$(STAMP) fit.chg

$(PROJECT).fit.rpt: fit.chg $(PROJECT).map.rpt
	quartus_fit $(FIT_ARGS) $(PROJECT)
	$(STAMP) asm.chg
	$(STAMP) tan.chg
	$(STAMP) sta.chg

$(PROJECT).asm.rpt: asm.chg $(PROJECT).fit.rpt
	quartus_asm $(ASM_ARGS) $(PROJECT)

$(PROJECT).tan.rpt: tan.chg $(PROJECT).fit.rpt
	quartus_tan $(TAN_ARGS) $(PROJECT) 

$(PROJECT).sta.rpt: sta.chg $(PROJECT).fit.rpt
	quartus_sta $(STA_ARGS) $(PROJECT) 

$(PROJECT).eda.rpt: eda.chg $(PROJECT).fit.rpt
	quartus_eda $(PROJECT) 

$(PROJECT).dse.rpt: $(ASSIGNMENT_FILES)
	quartus_sh --dse -nogui -project $(PROJECT) $(DSE_ARGS)

smart.log: $(ASSIGNMENT_FILES)
	quartus_sh --determine_smart_action $(PROJECT) > smart.log

###################################################################
# Project initialization
###################################################################

#$(ASSIGNMENT_FILES):
#	quartus_sh --prepare $(PROJECT)

map.chg:
	$(STAMP) map.chg
fit.chg:
	$(STAMP) fit.chg
tan.chg:
	$(STAMP) tan.chg
sta.chg:
	$(STAMP) sta.chg
asm.chg:
	$(STAMP) asm.chg
eda.chg:
	$(STAMP) eda.chg

.PHONY: dse
