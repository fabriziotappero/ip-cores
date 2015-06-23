GRLIB=../../
#WILDCARD_BASE={path to wildcard root directory}
TOP=wildfpga
BOARD=wildcard-xcv300e
include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
UCF=$(GRLIB)/boards/$(BOARD)/default.ucf
EFFORT=high
XSTOPT=
ISEMAPOPT="-r"
SYNPOPT="set_option -pipe 0; set_option -retiming 0; set_option -write_apr_constraint 0; set_option -resource_sharing 1"
VHDLSYNFILES=config.vhd wildfpga.vhd
VHDLSIMFILES=
SIMTOP=system_cfg
SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean

LIBSKIP=apa proasic3 axcelerator ecaltera altera_mf stratixii ec altera \
        eclipsee cycloneiii virage atc18 umc18 dw02 spw usbhc eth gleichmann \
        fmf spansion gsi cypress hynix ihp25 sgb25vrh ut025crh rh_lib18t ihp \
        artisan virage90 tsmc90 dare nextreme micron \
        core1553bbc core1553brt core1553brm corePCIF gr1553 openchip tmtc
DIRSKIP=spw usbhc spacewire greth grusbhc can leon3ft pcif b1553 crypto satcan
FILESKIP=simple_spi_top.v

include $(GRLIB)/software/leon3/Makefile
include $(GRLIB)/bin/Makefile

##################  project specific targets ##########################

