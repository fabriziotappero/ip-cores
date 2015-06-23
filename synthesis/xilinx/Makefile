MODULE=RS_dec
DEPS ?=
SOURCE_FILES ?= $(wildcard ../../rtl/*.v)

ADEPS ?=$(DEPS)
LIBS = ${ADEPS:%=-sd ../../../%/syn/xilinx}
MAP_OPTIONS ?= -timing
PAR_OPTIONS ?=

all: ${MODULE}.bit ${MODULE}.twr ${MODULE}_timesim.v

# (Re)generate $(MODULE).prj file:
config:
	echo -n > $(MODULE).prj
	for src in $(SOURCE_FILES); do \
		echo verilog work $$src >> $(MODULE).prj; \
	done
	$(foreach dir, ${ADEPS}, \
		for src in ../../../$(dir)/rtl/*.v; do \
			echo verilog work $$src >> $(MODULE).prj; \
		done; )

# Synthesize the HDL files into an NGC file.  This rule is triggered if
# any of the HDL files are changed or the synthesis options are changed.
%.ngc: %.xst
	echo "XST start: $$(date)" > time.log
	xst -intstyle silent -ifn $*.xst -ofn $*.syr
	echo "XST finish: $$(date)" >> time.log

# Take the output of the synthesizer and create the NGD file.  This rule
# will also be triggered if constraints file is changed.
%.ngd: %.ngc %.ucf
	ngdbuild -intstyle silent -dd _ngo $(LIBS) -uc $*.ucf $*.ngc $*.ngd

# Map the NGD file and physical-constraints to the FPGA to create the mapped NCD file.
%_map.ncd %.pcf: %.ngd
	echo "Map start: $$(date)" >> time.log
	map -intstyle silent $(MAP_OPTIONS) -o $*_map.ncd $*.ngd $*.pcf
	echo "Map finish: $$(date)" >> time.log

# Place & route the mapped NCD file to create the final NCD file.
%.ncd: %_map.ncd %.pcf
	echo "PAR start: $$(date)" >> time.log
	par -intstyle silent $(PAR_OPTIONS) $*_map.ncd $*.ncd $*.pcf
	echo "PAR finish: $$(date)" >> time.log

# Generate BIT file:
%.bit: %.ncd
	echo "bitgen start: $$(date)" >> time.log
	bitgen -intstyle silent -f ../../../include/syn/bitgen.ut $*.ncd
	echo "bitgen finish: $$(date)" >> time.log

# Create the FPGA timing report after place & route.
%.twr: %.ncd %.pcf
	echo "TRCE start: $$(date)" >> time.log
	trce -intstyle silent -v 3 -s 4 $*.ncd -o $*.twr $*.pcf
	echo "TRCE finish: $$(date)" >> time.log

%_timesim.v %_timesim.sdf: %.pcf %.ncd
	echo "netgen start: $$(date)" >> time.log
	netgen -intstyle silent -s 4 -pcf $*.pcf -sdf_anno true -insert_glbl true -w -ofmt verilog -sim $*.ncd $*_timesim.v
	echo "netgen finish: $$(date)" >> time.log

clean:
	${RM} *.bld *.map *.ncd *.ng? *.pad *.csv *.pcf *.nlf *.xpi *.bgn *.drc *.ngm *.ngr *.xrpt *.ise *.restore *twx time.log deps.v
	rm -rf _ngo xst _xmsgs *_xdb

all-clean: clean
	${RM} *.mrp *.par *.syr *.txt *.sdf *.twr *.unroutes *.xml *~ *.bit *_timesim.v *_pad.txt

# Preserve intermediate files.
.PRECIOUS: %.ngc %.ngd %_map.ncd %.ncd %.twr %.vm6 %.jed
