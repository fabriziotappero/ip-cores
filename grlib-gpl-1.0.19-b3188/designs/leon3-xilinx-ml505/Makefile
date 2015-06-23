GRLIB=../..
TOP=leon3mp
BOARD=xilinx-ml505-xc5vlx50t
include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
#UCF=$(GRLIB)/boards/$(BOARD)/$(TOP).ucf
UCF=leon3mp.ucf
XSTOPT= -uc leon3mp.xcf
QSF=$(GRLIB)/boards/$(BOARD)/$(TOP).qsf
EFFORT=high
ISEMAPOPT=-m
SYNPOPT="set_option -pipe 0; set_option -retiming 0; set_option -write_apr_constraint 0"
VHDLSYNFILES=config.vhd ahbrom.vhd leon3mp.vhd
VHDLSIMFILES=testbench.vhd
SIMTOP=testbench
#SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
SDCFILE=default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean

include $(GRLIB)/software/leon3/Makefile
XLDFLAGS=-L./ lib3tests.a -Ttext=0x40000000

TECHLIBS = unisim 
LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF \
	tmtc openchip ihp gleichmann usbhc spw
DIRSKIP = b1553 pcif leon2 leon2ft crypto satcan can ata pci leon3ft ambatest \
	grusbhc usb spacewire

FILESKIP = grcan.vhd simple_spi_top.v

include $(GRLIB)/bin/Makefile


##################  project specific targets ##########################

