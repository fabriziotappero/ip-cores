include .config
GRLIB=../..
TOP=leon3mp
BOARD=gr-cpci-xc4v
include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
UCF=$(GRLIB)/boards/$(BOARD)/$(TOP).ucf
QSF=$(GRLIB)/boards/$(BOARD)/$(TOP).qsf
EFFORT=high
XSTOPT=
ISEMAPOPT=-timing
VHDLSYNFILES=config.vhd leon3mp.vhd
VHDLSIMFILES=testbench.vhd
SIMTOP=testbench
SDCFILE=default.sdc
#SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean
SYNPOPT="set_option -pipe 0; set_option -retiming 0; set_option -write_apr_constraint 0"

TECHLIBS = unisim
LIBSKIP = core1553bbc core1553brm core1553brt gr1553 \
	tmtc openchip hynix cypress ihp gleichmann usbhc fmf spansion gsi
DIRSKIP = b1553 leon2 leon2ft leon3ft crypto satcan ddr usb ata grusbhc haps \
	slink ascs coremp7 ac97

include $(GRLIB)/bin/Makefile
include $(GRLIB)/software/leon3/Makefile


##################  project specific targets ##########################
