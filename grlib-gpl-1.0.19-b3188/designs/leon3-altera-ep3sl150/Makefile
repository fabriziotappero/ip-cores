GRLIB=../..
TOP=leon3mp
BOARD=altera-ep3sl150
include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
UCF=$(GRLIB)/boards/$(BOARD)/$(TOP).ucf
QSF=$(GRLIB)/boards/$(BOARD)/$(TOP).qsf
EFFORT=std
XSTOPT=
SYNPOPT="set_option -pipe 1; set_option -retiming 1"
VHDLSYNFILES=config.vhd ahbrom.vhd leon3mp.vhd 
VHDLSIMFILES=delay_wire.vhd testbench.vhd
SIMTOP=testbench
SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean

TECHLIBS = altera altera_mf stratixiii 
LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF fmf gsi \
	tmtc openchip ihp gleichmann stratixii usbhc spw spansion
DIRSKIP = b1553 pcif leon2 leon2ft crypto satcan pci leon3ft can \
	grusbhc spacewire haps ata usb
FILESKIP = grcan.vhd

include $(GRLIB)/software/leon3/Makefile
include $(GRLIB)/bin/Makefile


##################  project specific targets ##########################

