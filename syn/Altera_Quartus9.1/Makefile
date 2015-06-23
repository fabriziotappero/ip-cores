PROJECT=avs_aes

all: smart.log $(PROJECT).asm.rpt $(PROJECT).tan.rpt

clean:
	rm -rf *.rpt *.chg smart.log *msg *.htm *.eqn *.pin *.sof *.pof *.summary incremental_db 
clean_all: clean
	rm -rf *.ssf *.csf *.esf *.fsf *.psf *.quartus *.qws *.summary

$(PROJECT).map.rpt: map.chg $(SOURCE_FILES)
	quartus_map $(MAP_ARGS) $(PROJECT)
	$(STAMP) fit.chg
$(PROJECT).fit.rpt: fit.chg $(PROJECT).map.rpt
	quartus_fit $(FIT_ARGS) $(PROJECT)
	$(STAMP) asm.chg
	$(STAMP) tan.chg
$(PROJECT).asm.rpt: asm.chg $(PROJECT).fit.rpt
	quartus_asm $(ASM_ARGS) $(PROJECT)
$(PROJECT).tan.rpt: tan.chg $(PROJECT).fit.rpt
	quartus_tan $(TAN_ARGS) $(PROJECT)
smart.log: $(ASSIGNMENT_FILES)
	quartus_sh --determine_smart_action $(PROJECT) > smart.log


################################################################
# Target implementations
################################################################
STAMP = echo done >


################################################################
# Project initialization
################################################################

map.chg:
	$(STAMP) map.chg
fit.chg: 
	$(STAMP)	fit.chg
tan.chg: 
	$(STAMP)	tan.chg
asm.chg:
	$(STAMP)	asm.chg

