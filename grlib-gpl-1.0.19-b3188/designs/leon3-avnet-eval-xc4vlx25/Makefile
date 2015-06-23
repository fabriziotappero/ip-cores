include .config
GRLIB=../..
TOP=leon3mp
BOARD=avnet-eval-xc4vlx25
include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
#UCF=$(GRLIB)/boards/$(BOARD)/$(TOP).ucf
#UCF=$(GRLIB)/boards/$(BOARD)/leon3mp.ucf
UCF=leon3mp.ucf
QSF=$(GRLIB)/boards/$(BOARD)/$(TOP).qsf
EFFORT=med
XSTOPT=-uc leon3mp.xcf
SYNPOPT="set_option -pipe 1; set_option -retiming 1; set_option -write_apr_constraint 0"
VHDLSYNFILES=config.vhd ahbrom.vhd leon3mp.vhd
VHDLSIMFILES=testbench.vhd
SIMTOP=testbench
#SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
SDCFILE=default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean

TECHLIBS = unisim
LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF \
	tmtc openchip hynix cypress ihp gleichmann usbhc spw
DIRSKIP = b1553 pcif leon2 leon2ft crypto satcan pci leon3ft \
	spacewire ambatest can grusbhc usb hasp
FILESKIP = grcan.vhd i2cmst.vhd



include $(GRLIB)/bin/Makefile
include $(GRLIB)/software/leon3/Makefile
#XLDFLAGS=-L./ lib3tests.a -Ttext=0x60000000


##################  project specific targets ##########################
