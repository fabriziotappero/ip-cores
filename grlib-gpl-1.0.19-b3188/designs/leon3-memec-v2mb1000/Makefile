GRLIB=../..
TOP=leon3mp
BOARD=memec-v2-mb1000
include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
#UCF=$(GRLIB)/boards/$(BOARD)/$(TOP).ucf
#UCF=$(GRLIB)/boards/$(BOARD)/leon3mp.ucf
UCF=leon3mp.ucf
QSF=$(GRLIB)/boards/$(BOARD)/$(TOP).qsf
EFFORT=med
XSTOPT=-uc leon3mp.xcf
VHDLSYNFILES=config.vhd ahbrom.vhd leon3mp.vhd
VHDLSIMFILES=testbench.vhd
SIMTOP=testbench
#SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
SDCFILE=default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean

TECHLIBS = unisim
LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF \
	tmtc openchip hynix ihp gleichmann opencores usbhc
DIRSKIP = b1553 pcif leon2 leon2ft crypto satcan pci leon3ft ambatest can \
	usb grusbhc haps
FILESKIP = grcan.vhd i2cmst.vhd

include $(GRLIB)/bin/Makefile
include $(GRLIB)/software/leon3/Makefile
#XLDFLAGS=-L./ lib3tests.a -Ttext=0x60000000


##################  project specific targets ##########################
