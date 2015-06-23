GRLIB=../..
TOP=leon3mini
BOARD=ge-hpe-mini-lattice
include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
UCF=$(GRLIB)/boards/$(BOARD)/$(TOP).lpf
QSF=$(GRLIB)/boards/$(BOARD)/$(TOP).qsf
EFFORT=1
XSTOPT=
VHDLSYNFILES=config.vhd ahbrom.vhd clkgen_lattice_ea.vhd leon3mini.vhd
VHDLSIMFILES=testbench.vhd
SIMTOP=testbench
SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean

TECHLIBS = ec 
LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF \
	tmtc openchip cypress ihp usbhc gleichmann
DIRSKIP = pcif leon2 leon2ft crypto pci ambatest usb grusbhc b1553 satcan usbhc
FILESKIP = vgaclkgen.vhd

include $(GRLIB)/bin/Makefile
include $(GRLIB)/software/leon3/Makefile
XLDFLAGS=-L./ lib3tests.a -Ttext=0x60000000


##################  project specific targets ##########################
