GRLIB=../..
TOP=leon3mp
BOARD=gr-cpci-xc4v
include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
UCF=$(GRLIB)/boards/$(BOARD)/$(TOP).ucf
QSF=$(GRLIB)/boards/$(BOARD)/$(TOP).qsf
EFFORT=std
XSTOPT=
VHDLSYNFILES=config.vhd ahbrom.vhd \
	leon3core.vhd core.vhd pads.vhd leon3mp.vhd

VHDLSIMFILES=testbench.vhd
SIMTOP=testbench
SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean
DCSCRIPT=ut025crh.tcl

TECHLIBS = nextreme virage atc18 artisan virage90 tsmc90 umc18 cust1
LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF \
	openchip gleichmann gsi spansion
DIRSKIP = b1553 pcif leon2 leon2ft 
	
FILESKIP =


include $(GRLIB)/bin/Makefile
include $(GRLIB)/software/leon3/Makefile


##################  project specific targets ##########################
