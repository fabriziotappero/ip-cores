GRLIB=../..
TOP=leon3mp
BOARD=digilent-xup-xc2vp
include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
#UCF=$(GRLIB)/boards/$(BOARD)/$(TOP).ucf
UCF=leon3mp.ucf
QSF=$(GRLIB)/boards/$(BOARD)/$(TOP).qsf
EFFORT=high
SYNPOPT="set_option -pipe 1; set_option -retiming 1; set_option -write_apr_constraint 0"
XSTOPT=-uc leon3mp.xcf
VHDLSYNFILES=config.vhd ahbrom.vhd leon3mp.vhd
VHDLSIMFILES=testbench.vhd
SIMTOP=testbench
#SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
SDCFILE=default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean

TECHLIBS = unisim
LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF usbhc hynix \
	tmtc openchip cypress ihp gleichmann opencores spw fmf gsi spansion
DIRSKIP = b1553 pcif leon2 leon2ft crypto satcan pci leon3ft ambatest \
	ata can usb spacewire grusbhc
FILESKIP = grcan.vhd i2cmst.vhd

include $(GRLIB)/bin/Makefile
include $(GRLIB)/software/leon3/Makefile

#XLDFLAGS = -N -g -O2 -qprom -qsvt bdinit.c dump.s -L./ lib3tests.a -lmkprom3

##################  project specific targets ##########################

