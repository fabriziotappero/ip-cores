# to be included in design makefile
#CONFDEVICE=EPM1270

TECHNOLOGY= STRATIXII
PART= EP2S60
PACKAGE= FC1020
SPEED=-3
SYNFREQ=60
CONFDEVICE=EPCS64

ALTERA_PINGEN=altera_pingen.awk
BOARD_DIR=$(GRLIB)/boards/$(BOARD)

$(BOARD_DIR)/leon_pinning.csv: $(BOARD_DIR)/LEON-MIDI-Vers1_1-AS2-Vers1_1-Pinning.csv
	grep -v "Pin;Port;NetName" $< > $@

$(BOARD_DIR)/leon_pinning.txt: $(BOARD_DIR)/leon_pinning.csv
	$(ALTERA_PINGEN) FS=";" $< > $@

board-pinning-clean:
	-rm -f $(BOARD_DIR)/leon_pinning.csv \
	   $(BOARD_DIR)/leon_pinning.txt

board-pinning-check: $(BOARD_DIR)/leon_pinning.txt
	@echo
	@echo "Searching for pin double assignments..."
	@for i in `sort --key=1 --field-separator=";" $< | cut --fields="1-1" --delimiter=";" | uniq --repeated`; do grep $$i $<; done
