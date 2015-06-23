GRLIB=../..
TOP=leon3mini
BOARD=ge-hpe-mini
include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
UCF=$(GRLIB)/boards/$(BOARD)/$(TOP).ucf
QSF=$(GRLIB)/boards/$(BOARD)/$(TOP).qsf
EFFORT=1
XSTOPT=
VHDLSYNFILES=config.vhd ahbrom.vhd leon3mini.vhd
VHDLSIMFILES=testbench.vhd
SIMTOP=testbench
SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean

# Select your cable type here.
# Make sure it has been installed via the programmer GUI
# in Quartus.
#
# Examples:
#   USB-Blaster
#   ByteBlasterMV
CABLE=ByteBlasterMV

TECHLIBS = altera altera_mf 
LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF \
	tmtc openchip hynix cypress ihp stratixii usbhc spw
DIRSKIP = b1553 pcif leon2 leon2ft crypto satcan pci leon3ft ambatest ddr \
	grusbhc spacewire


INCLUDEFILES=$(VPATH)/hpi_functions.c

include $(GRLIB)/bin/Makefile
include $(GRLIB)/software/leon3/Makefile


##################  project specific targets ##########################

quartus-pgm:
	quartus_pgm -c $(CABLE) -m JTAG -o p\;$(TOP).sof

hpi_new.exe: hpi_new.c
	$(XCC) $(CFLAGS) $(INCLUDEFILES) $< -o hpi_new.exe

hello.exe: hello.c
	$(XCC) $(CFLAGS) $< -o hello.exe

