GRLIB=../..
TOP=leon3ax
BOARD=gr-cpci-ax
include $(GRLIB)/boards/$(BOARD)/Makefile.inc

DEVICE=$(PART)-$(PACKAGE)$(SPEED)
SDC=$(GRLIB)/boards/$(BOARD)/designer_$(DESIGNER_PINS)_$(DESIGNER_PACKAGE).sdc
PDC=$(GRLIB)/boards/$(BOARD)/designer_$(DESIGNER_PINS)_$(DESIGNER_PACKAGE).pdc

EFFORT=1
XSTOPT=-fsm_extract no
VHDLSYNFILES=config.vhd leon3ax.vhd
VHDLSIMFILES=pcitb_stimgen.vhd testbench.vhd
SIMTOP=testbench

SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean

TECHLIBS = axcelerator
LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF \
	tmtc openchip hynix cypress ihp gleichmann opencores usbhc fmf \
	spansion gsi
DIRSKIP = b1553 pcif leon2 leon2ft crypto satcan ddr can \
	greth usb ata slink ascs haps coremp7
FILESKIP = grcan.vhd i2cmst.vhd

include $(GRLIB)/bin/Makefile
include $(GRLIB)/software/leon3/Makefile

##################  project specific targets ##########################


vsim-axcelerator: modelsim
	@-vlib modelsim/axcelerator
	@-vmap axcelerator modelsim/axcelerator
	$(VCOM) axcelerator "$(ACTEL)/lib/vtl/95/axcelerator.vhd"

vsim-gate: vsim-axcelerator
	$(VCOM) work actel/$(TOP).vhd

vsim-gate-run:
	vsim -c -noglitch -multisource_delay max -sdfmax d3=actel/$(TOP).sdf -sdfnowarn -t ps work.testbench

vsim-gate-launch:
	vsim    -noglitch -multisource_delay max -sdfmax d3=actel/$(TOP).sdf -sdfnowarn -t ps work.testbench

all: help local-help

local-help:
	@echo "local targets:"
	@echo
	@echo " make vsim-gate            : compile  gate-level with modelsim "
	@echo " make vsim-gate-run        : simulate gate-level with modelsim in batch"
	@echo " make vsim-gate-launch     : simulate gate-level with modelsim "
	@echo	


