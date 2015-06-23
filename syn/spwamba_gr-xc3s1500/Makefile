#
# Makefile for a LEON3 with SpaceWire Light on a Pender GR-XC3S1500 board.
#

-include .config

# Change this to your local GRLIB directory.
GRLIB = /data/leon3/grlib-gpl-1.2.2-b4123

TOP=leon3mp
BOARD=gr-xc3s-1500
include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
UCF=leon3mp.ucf
QSF=$(GRLIB)/boards/$(BOARD)/$(TOP).qsf
EFFORT=high
ISEMAPOPT=-timing
XSTOPT=
SYNPOPT="set_option -pipe 0; set_option -retiming 0; set_option -write_apr_constraint 0"
SDCFILE=default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
VCOMOPT=-explicit
TECHLIBS = unisim

LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF \
	tmtc openchip hynix cypress ihp gleichmann gsi fmf spansion
DIRSKIP = b1553 pcif leon2 leon2ft crypto satcan pci leon3ft ambatest ddr \
	haps ascs slink coremp7
FILESKIP = grcan.vhd

RTLDIR = ../../rtl/vhdl
VHDLSYNFILES = config.vhd leon3mp.vhd \
  $(RTLDIR)/spwpkg.vhd      \
  $(RTLDIR)/spwlink.vhd     \
  $(RTLDIR)/spwrecv.vhd     \
  $(RTLDIR)/spwxmit.vhd     \
  $(RTLDIR)/spwxmit_fast.vhd \
  $(RTLDIR)/spwrecvfront_generic.vhd \
  $(RTLDIR)/spwrecvfront_fast.vhd \
  $(RTLDIR)/syncdff.vhd \
  $(RTLDIR)/spwram.vhd \
  $(RTLDIR)/spwambapkg.vhd  \
  $(RTLDIR)/spwamba.vhd     \
  $(RTLDIR)/spwahbmst.vhd   \

include $(GRLIB)/bin/Makefile

.config:
	cp -a defconfig .config

