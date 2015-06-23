VER=1.0.19
GVER=1019
CC=gcc
SED=sed
DISTLIB=~/vhdl

ASICLIBS = ihp25 sgb25vrh ut025crh virage rh_lib18t rh_lib18t_io2 \
	atc18 artisan umc18 virage90 tsmc90 dare nextreme atc18rha_cell
FPGALIBS = apa proasic3 axcelerator ec unisim altera altera_mf stratixii \
	eclipsee cycloneiii stratixiii synplify simprim
ifeq ("$(TECHLIBS)","")
TECHLIBS=$(FPGALIBS) $(ASICLIBS)
endif
XTECHLIBS = $(TECHLIBS:%=tech/% )
SIMLIBS = hynix micron cypress
ACTELLIBS = apa apa3 axcelerator
XILINXLIBS = unisim simprim
ALTERALIBS = altera_mf stratixii altera cycloneiii stratixiii
LATTICELIBS = ec
BRMLIBS = core1553bbc core1553brm core1553brt gr1553
COREPCILIB = corePCIF
CONTRIBLIBS = openchip gleichmann contrib sun

RMFTLIBS=ihp25 sgb25vrh ut025crh rh_lib18t rh_lib18t_io2 pere05 rhumc \
	dare tsmc90 atc18rha_cell
RMCOMLIBS=artisan cust1 virage90 nextreme

RMFTLIBSX = $(RMFTLIBS:%=lib/techmap/%) $(RMFTLIBS:%=lib/tech/%)
RMCOMLIBSX = $(RMCOMLIBS:%=lib/techmap/%) $(RMCOMLIBS:%=lib/tech/%)
RMFPGALIBSX = $(ASICLIBS:%=lib/techmap/%) $(ASICLIBS:%=lib/tech/%)

HAPSFILES = lib/gaisler/haps doc/haps.pdf boards/hardi* designs/leon3-hardi*

INTFILES =  TODO.txt \
	boards/*/doc \
	doc/crypto doc/companion-core doc/design-reuse doc/esa \
	doc/gr1553 doc/greth doc/grspw \
	lib/actel/*/source \
	lib/esa/leon2* lib/gaisler/fpu \
	lib/gaisler/leon3ft lib/gaisler/pcif lib/gaisler/satcan \
	lib/gaisler/crypto lib/ihp* \
	lib/gaisler/slink \
	$(RMFTLIBSX) lib/tech/nextreme/cells \
	lib/topnet lib/tmtc \
	designs/suidemo \
	designs/*esa* designs/leon3-ft-a* designs/leon3-ft-d* \
	designs/leon3-ft-r* designs/leon3-ft-m* \
	designs/leon3-ft-*flex designs/leon3-celeno designs/leon3ihp-tbench \
	designs/*flexody* designs/*/rhlib* \
	designs/*-cosim designs/leon2-gr-cpci-xc4v \
	designs/leon2* \
	designs/ethspw designs/leon3ihp designs/pcispw \
	designs/leon3-1553 \
	designs/gr701-pci-1553-bridge \
	designs/rasta-if-board designs/leon3-bsd \
	verification/ahbctrl \
	verification/b1553brm \
	verification/dma2ahb verification/esa_spw \
	verification/grslink verification/grspw \
	verification/spimctrl \
	verification/tb_msp verification/rs_gf4_16_8 \
	verification/tmtc \
	lib/spansion/flash/s29gl128p.vhd lib/spansion/flash/s29gl128p_vhd.ftm \
	lib/techmap/*/usbhc_unisim_* netlists/xilinx/spartan3/grspwc2.ngo\
	lib/techmap/*/corepcif_* lib/actel/corePCIF/netlist \
	lib/tech/atc18/cells lib/tech/atc18rha_cell\
	lib/techmap/*/pci_arb_* lib/gaisler/ascs \
	software/leon3/grslink.c software/leon3/grascs.c \
	lib/tech/*/doc lib/gaisler/haps/ddr2_1x2* \
	lib/tech/tsmc90/tci

FTFILES =  \
	doc/reedsolomon doc/tmtc \
	designs/leon3-rtax* designs/leon3-ft* \
	verification/ft* \
	lib/actel \
	lib/gaisler/*/*ft* lib/gaisler/misc/ft* \
	lib/gaisler/b1553 lib/gr1553 \
	lib/grlib/ftlib \
	lib/micron/sdram/ft* \
	lib/techmap/maps/*ft* \
	lib/spw/core \
	lib/techmap/*/grspwc_*_*.vhd \
	lib/techmap/*/leon3ft*_*.vhd \
	lib/techmap/*/ftmctrl_*_*.vhd \
	software/leon3/*ft* software/leon3/bch* \
	software/leon3/brm.c 

USBFILES = \
	verification/grusbhc verification/usbdcl verification/grusbdc \
	lib/gaisler/usb/hc lib/gaisler/usb/dc lib/gaisler/usb/dcl \
	lib/techmap/*/usbhc_*_*.vhd

GBITFILES = \
	verification/greth/*gbit* \
	lib/eth/core/*gbit*

T1FILES = lib/sun designs/t1*

COREMP7FILES = lib/gaisler/coremp7 designs/coremp7-actel-proasic3

COMFILES = \
	designs/leon3-clk2x designs/*spw* \
	verification/greth verification/spictrl verification/i2c \
	verification/pci verification/can_oc \
	verification/mobile_ddr_sdr \
	lib/grlib/amba/ahbmon.vhd lib/grlib/amba/apbmon.vhd \
	lib/grlib/amba/ambamon.vhd lib/grlib/amba/ahbctrl_mb.vhd \
	lib/gaisler/misc/ahb2ahb.vhd lib/gaisler/misc/ahbbridge.vhd \
	lib/gaisler/leon3/*2x*  lib/gaisler/memctrl/ssrctrl.vhd \
	lib/gaisler/misc/grfifo* \
	lib/gaisler/misc/gradcdac* \
	lib/gaisler/can/can_core.vhd lib/gaisler/can/grcan.vhd \
	lib/gaisler/can/can_top_core_sync.vhd lib/opencores/can/can_top_sync.vhd \
	lib/gaisler/sim/ulpi.vhd lib/gaisler/sim/utmi.vhd \
	lib/techmap/inferred/tap_inferred.vhd \
	$(USBFILES) $(RMCOMLIBSX) $(GBITFILES)

INTFTFPGAFILES = \
	verification/greth verification/greth/*gbit* \
	designs/leon3-clk2x lib/gaisler/greth/*gbit* \
	lib/grlib/amba/ahbctrl_mb.vhd \
	lib/gaisler/misc/ahb2ahb.vhd lib/gaisler/misc/ahbbridge.vhd \
	lib/gaisler/usb/usbdclc.vhd lib/usbhc/core \
	lib/gaisler/leon3/*2x* lib/gaisler/memctrl/ssrctrl.vhd \
	lib/gaisler/greth/*gbit* \
	lib/gaisler/memctrl/ftsrctrl-v1.* \
	lib/gleichmann lib/openchip \
	lib/tech/altera lib/techmap/altera \
	lib/tech/cycloneiii lib/techmap/cycloneiii \
	lib/tech/stratixiii lib/techmap/stratixiii \
	lib/tech/altera_mf lib/techmap/altera_mf \
	lib/tech/stratixii lib/techmap/stratixii \
	lib/tech/apa lib/techmap/apa \
	lib/tech/proasic3 lib/techmap/proasic3 \
	lib/tech/ec lib/techmap/ec \
	designs/leon3-altera* designs/leon3-avnet* designs/leon3-clock-gate \
	designs/leon3-digilent* designs/leon3-xilinx* \
	designs/leon3-nuhorizons-3s1500 \
	designs/leon3-jopdesign-ep1c12 designs/leon3-ge-* \
	designs/leon3-gr-cpci* designs/leon3-gr-pci* \
	designs/leon3-memec-v2mb1000 designs/leon3-actel* \
	designs/ut699rh-evab \
	verification/grusbhc verification/usbdcl \
	lib/gaisler/sim/ulpi.vhd lib/gaisler/sim/utmi.vhd \
	designs/actel-coremp7-1000 \
	netlists/altera netlists/xilinx/*/grfpw*  netlists/xilinx/*/xst

INTFPGAFILES = \
	verification/greth verification/greth/*gbit* \
	designs/leon3-clk2x lib/gaisler/greth/*gbit* \
	lib/grlib/amba/ahbctrl_mb.vhd \
	lib/gaisler/misc/ahb2ahb.vhd lib/gaisler/misc/ahbbridge.vhd \
	lib/gaisler/usb/usbdclc.vhd lib/gaisler/usb/grusb.vhd \
	lib/gaisler/leon3/*2x* lib/gaisler/memctrl/ssrctrl.vhd \
	lib/gaisler/greth/*gbit* \
	lib/gaisler/memctrl/ftsrctrl-v1.* \
	lib/gleichmann lib/openchip \
	designs/leon3-jopdesign-ep1c12 \
	designs/leon3-clock-gate \
	designs/leon3-asic \
	designs/leon3-ge-*

VHDLP = vhdlp -s -work
SONATALIBSKIP = pere05

ALIB = alib
ACOM = acom -quiet $(ACOMOPT) -accept87 -work
ALOG = alog -quiet $(ALOGOPT) -work
AVHDL = avhdl

VLIB = vlib
VCOM = vcom -quiet $(VCOMOPT) -93 -work
VLOG = vlog -quiet $(VLOGOPT) -work
VSIM = vsim

NCVHDL = ncvhdl -nowarn DLCPTH -NOVITALCHECK -linedebug -v93 -nocopyright -work
NCVLOG = ncvlog -nowarn DLCPTH -nocopyright $(NCVLOGOPT) -work

DCVHDL = analyze -f VHDL -library
DCVLOG = analyze -f VERILOG -library
ifeq ("$(DCSCRIPT)","")
DCSCRIPT=$(TOP).dc
endif
DCLIBSKIP = $(FPGALIBS) dw02 corePCIF
#DCLIBSKIP = dw02 corePCIF
DCDIRSKIP =  $(FPGALIBS) corePCIF pcif
#DCDIRSKIP =  corePCIF pcif
XDCLIBSKIP = $(DCLIBSKIP:%=% | ) dummy
XDCDIRSKIP = $(DCDIRSKIP:%=% | ) dummy
DCSKIP = $(DCLIBSKIP:%=*_%.vhd | ) dummy

RTLCVHDL = read_hdl -vhdl -lib
RTLCVLOG = read_hdl
RCSCRIPT=$(TOP).rc

SYNPVHDL = add_file -vhdl -lib
SYNPVLOG = add_file -verilog
SYNPLIBSKIP = $(ASICLIBS)
XSYNPLIBSKIP = $(SYNPLIBSKIP:%=%|) dw02
XSYNPDIRSKIP = $(SYNPLIBSKIP:%=%|) dw02

XSTVHDL = elaborate -ifmt vhdl -work_lib
XSTVLOG = elaborate -ifmt verilog -work_lib
XSTLIBSKIPX = $(ASICLIBS) $(BRMLIBS) $(ACTELLIBS) $(ALTERALIBS) \
	$(LATTICELIBS) $(COREPCILIB) $(SIMLIBS)
XSTLIBSKIP = $(XSTLIBSKIPX:%=%|) dw02
XSTDIRSKIPX = $(ASICLIBS) $(ACTELLIBS) $(ALTERALIBS) $(LATTICELIBS) grfpu grfpc grlfpc
XSTDIRSKIP = $(XSTDIRSKIPX:%=%|) dw02
#XSTSKIPX = $(XSTLIBSKIPX:%=*_%.vhd |)
XSTSKIP = $(XSTSKIPX) b1553* | pci_components* | pcicore* | snpsmul.vhd

ifeq ("$(ISETECH)","")
ISETECH=$(TECHNOLOGY)
endif

PRECLIBSKIPX = $(SIMLIBS) $(ASICLIBS)
PRECLIBSKIP =  $(PRECLIBSKIPX:%=%|) dw02
PRECDIRSKIP =  $(PRECLIBSKIPX:%=%|) dw02
PRECSKIP = dummy

XLIBEROLIBSKIP = $(ASICLIBS) $(LATTICELIBS) \
	$(ALTERALIBS) $(XILINXLIBS)
LIBEROLIBSKIP = $(XLIBEROLIBSKIP:%=%|) dw02
LIBERODIRSKIPX = $(ASICLIBS) $(XILINXLIBS) $(ALTERALIBS) $(LATTICELIBS)
LIBERODIRSKIP = $(LIBERODIRSKIPX:%=%|) dw02
LIBEROSKIP = dummy

# The paths below apply to CoreConsole v. 1.4
ifeq ("$(CORECONSOLE)","")
CORECONSOLE = dummy
else
CORECONSOLE_PATH = $(CORECONSOLE)/repository/Components/Actel/DirectCore
COREMP7BRIDGE_PATH = $(CORECONSOLE_PATH)/CoreMP7Bridge/2.1/rtl/vhdl/o
COREMP7BRIDGE_FILES = A7WrapMaster.vhd A7WrapSM.vhd CoreMP7Bridge_a3p.vhd Sync.vhd uj_jtag.vhd
COREMP7_PATH = $(CORECONSOLE_PATH)/A7S/2.0/M7A3P1000-2/debug/timingshell/vhdl
COREMP7_FILES = arm_synplify.vhd
endif

SYNPSKIP = snpsmul.vhd

GHDL = ghdl -a --ieee=synopsys
GHDLE = ghdl -e --ieee=synopsys
GHDLM = ghdl --gen-makefile --ieee=synopsys
GHDLSKIP = orca.vhd _ec.vhd grcan.vhd

SYNPLIFY = synplify_pro

DESIGNER = designer
LIBERO = libero

OS = `uname`

UNISIM = $(XILINX)/vhdl/src/unisims/unisim_VPKG.vhd  \
	$(XILINX)/vhdl/src/unisims/unisim_VCOMP.vhd \
	$(XILINX)/vhdl/src/unisims/unisim_VITAL.vhd

SIMPRIM = $(XILINX)/vhdl/src/simprims/simprim_Vpackage.vhd  \
	$(XILINX)/vhdl/src/simprims/simprim_Vcomponents.vhd \
	$(XILINX)/vhdl/src/simprims/simprim_VITAL.vhd


#ifeq ("$(QUARTUS_ROOTDIR)","")
QUARTUS_MAP = quartus_map
QUARTUS_FIT = quartus_fit
QUARTUS_ASM = quartus_asm
QUARTUS_TAN = quartus_tan
QUARTUS_PGM = quartus_pgm
#else
#QUARTUS_MAP = $(QUARTUS_ROOTDIR)/bin/quartus_map
#QUARTUS_FIT = $(QUARTUS_ROOTDIR)/bin/quartus_fit
#QUARTUS_ASM = $(QUARTUS_ROOTDIR)/bin/quartus_asm
#QUARTUS_TAN = $(QUARTUS_ROOTDIR)/bin/quartus_tan
#endif
ALTCABLE=USB-Blaster
QLIBSKIPX = $(SIMLIBS) $(ASICLIBS) $(BRMLIBS) $(ACTELLIBS) $(XILINXLIBS) \
	$(LATTICELIBS) $(COREPCILIB)
QUARTUSLIBSKIP = $(QLIBSKIPX:%=%|) dw02
QDIRSKIPX = $(ASICLIBS) $(ACTELLIBS) $(XILINXLIBS) $(LATTICELIBS)
QDIRSKIP = $(QDIRSKIPX:%=%|) dw02 | satcan | leon2ft
QUARTUSSKIP = b1553* | pci_components* | pcicore* | snpsmul.vhd | \
	grfpw_* | grlfpw_* | usbhc_stratixii.vhd | usbhc_stratixiipkg.vhd

SYN=synplify
SIM=$(VSIM)
PR=ise

PRECISION=precision

ifeq ("$(SIMTOP)","")
SIMTOP=$(TOP)
endif

ifeq ("$(LIBSKIP)","")
XLIBSKIP="x"
else
XLIBSKIP= $(LIBSKIP:%=%|) dummy
endif

YDIRSKIP=$(DIRSKIP) $(LIBSKIP)

ifeq ("$(YDIRSKIP)","")
XDIRSKIP="dummy"
else
XDIRSKIP= $(YDIRSKIP:%=%|) $(LIBSKIP:%=%|) dummy
endif

XFILESKIP = $(FILESKIP:%=%|) $(LIBSKIP:%=*_%.vhd|) dummy

all: help

help:
	@echo
	@echo " interactive targets:"
	@echo
	@echo " make avhdl-launch         : start active-hdl gui mode"
	@echo " make riviera-launch       : start riviera"
	@echo " make vsim-launch          : start modelsim"
	@echo " make ncsim-launch         : compile design using ncsim"
	@echo " make sonata-launch        : compile design using sonata"
	@echo " make actel-launch-synp    : start Actel Designer for current project"
	@echo " make ise-launch           : start ISE project navigator for XST project"
	@echo " make ise-launch-synp      : start ISE project navigator for synplify project"
	@echo " make quartus-launch       : start Quartus for current project"
	@echo " make quartus-launch-synp  : start Quartus for synplify project"
	@echo " make synplify-launch      : start synplify"
	@echo " make xgrlib               : start grlib GUI"
	@echo
	@echo " batch targets:"
	@echo
	@echo " make avhdl           : compile design using active-hdl gui mode"
	@echo " make vsimsa          : compile design using active-hdl batch mode"
	@echo " make riviera         : compile design using riviera"
	@echo " make sonata          : compile design using sonata"
	@echo " make vsim            : compile design using modelsim"
	@echo " make ncsim           : compile design using ncsim"
	@echo " make ghdl            : compile design using GHDL"
	@echo " make actel           : synthesize with synplify, place&route Actel Designer"
	@echo " make ise             : synthesize and place&route with Xilinx ISE"
	@echo " make ise-map         : synthesize design using Xilinx XST"
	@echo " make ise-prec        : synthesize with precision, place&route with Xilinx ISE"
	@echo " make ise-synp        : synthesize with synplify, place&route with Xilinx ISE"
	@echo " make isp-synp        : synthesize with synplify, place&route with ISPLever"
	@echo " make quartus         : synthesize and place&route using Quartus"
	@echo " make quartus-map     : synthesize design using Quartus"
	@echo " make quartus-synp    : synthesize with synplify, place&route with Quartus"
	@echo " make precision       : synthesize design using precision"
	@echo " make synplify        : synthesize design using synplify"
	@echo " make import-actel-cc : import CoreMP7 files from CoreConsole library"
	@echo " make scripts         : generate compile scripts only"
	@echo " make clean           : remove all temporary files except scripts"
	@echo " make distclean       : remove all temporary files"
	@echo

make xgrlib:
	  @if test -r "/mingw/bin/wish84.exe"; then \
	    if !(test -r "/mingw/bin/echo.bat"); then \
	      cp $(GRLIB)/bin/echo.bat /mingw/bin/echo.bat; \
	    fi; \
	    if !(test -r "/mingw/bin/wish"); then \
	      cp $(GRLIB)/bin/wish /mingw/bin/wish; \
	    fi; \
	  fi; \
	$(GRLIB)/bin/xgrlib.tcl $(TOP) $(TECHNOLOGY) $(DEVICE) $(BOARD)

############  AHB ROM Geneartion     ########################

FILE=prom.exe

ahbrom: $(GRLIB)/bin/ahbrom.c
	$(CC) $(GRLIB)/bin/ahbrom.c -o ahbrom

ahbrom.vhd:
	make ahbrom
	sparc-elf-objcopy -O binary $(FILE) ahbrom.bin
	./ahbrom ahbrom.bin ahbrom.vhd

#########    Generic simulation target ###############

sim:
	make $(SIM)

sim-run:
	make $(SIM)-run

sim-launch:
	make $(SIM)-launch

#########    Symphony-EDA Sonata targets   ############

make.son: compile.son
sonata sonata/compiled : make.son
	@make -f make.son sonata-compile
	@touch sonata/compiled

sonata-run : sonata/compiled
	vhdle -ini sonata.sws -work sonata -breakon FAILURE -r 1ps testbench

sonata-launch : sonata/compiled
	sonata sonata.sws

sonata-clean:
	-rm -rf *\.sym sonata.sws sonata symphony.ini symphony.sws tmp.son

#########    Active-HDL batch mode targets   ############

vsimsa: compile.vsim
	@cat libs.do | sed -e s/modelsim/activehdl/ | sed -e s/vlib/alib/ > alibs-batch.do
	@echo "do alibs-batch.do" > vsimsa-batch.do
	@vsimsa vsimsa-batch.do
	@vmap work activehdl/work
	@make -f make.vsim
	@-rm -f alibs-batch.do vsimsa-batch.do

vsimsa-run:
	@vsim $(SIMTOP) <  $(GRLIB)/bin/runvsim.do

vsimsa-launch: vsimsa-run

vsimsa-clean:
	-rm -rf activehdl vsimsa.cfg library.cfg wave.asdb alibs-batch.do vsimsa-batch.do

#vsimsa-modelsim:
#	echo "importmodelsim $(SIMTOP).mpf" . > activehdl.tcl
#	echo "quiet on" >> activehdl.tcl
#	echo "SET SIM_WORKING_FOLDER ..\\.." >> activehdl.tcl
#	AVHDL -do activehdl.tcl &

#########    Active-HDL gui mode targets   ############

avhdl: compile.asim
	@echo "createdesign work ." > avhdl.tcl
	@echo "opendesign -a work.adf" >> avhdl.tcl
	@cat alibs.do >> avhdl.tcl
	@echo "" >> avhdl.tcl
	@cat make.asim-addfile >> avhdl.tcl
	@cat make.asim >> avhdl.tcl
	@echo "" >> avhdl.tcl
	@echo SET SIM_WORKING_FOLDER $$\DSN/.. >> avhdl.tcl
	@echo "" >> avhdl.tcl
	@echo asim work.testbench >> avhdl.tcl

avhdl-run: avhdl-launch

avhdl-launch:
	@avhdl -do avhdl.tcl

avhdl-clean:
	-rm -rf work avhdl.tcl vsimsa.cfg wave.asdb

#########    Riviera targets   ############

riviera: compile.vsim
	@cat libs.do | sed -e s/modelsim/riviera/ > rlibs.do
	@vsimsa rlibs.do
	@make -f make.vsim
	@vmap work riviera/work
	@-rm -f rlibs.do

riviera-run:
	@vsim $(SIMTOP) <  $(GRLIB)/bin/runvsim.do

riviera-launch:
	@echo asim $(SIMTOP) > riviera.do
	@echo run -all >> riviera.do
	@echo abort >> riviera.do
	@riviera riviera.do

riviera-clean:
	-rm -rf riviera vsimsa.cfg wave.asdb riviera.do library.cfg .riviera_project rlibs.do

#########    Modelsim targets   ############

vsim: make.work
	@make -f make.work

make.work: compile.vsim modelsim
	@make -f make.vsim
	@echo "" > make.work
	@for i in `cat libs.txt`; do vmake $$i >> make.work ; done

modelsim: compile.vsim
	@vsim -c -quiet -do "do libs.do; quit"

vsim-grlib: modelsim
	make vsim
#	@for i in `cat libs.txt`; do \
#	  make -f modelsim/make.$$i ; \
#	done ;

vsim-run: vsim
	@vsim -c $(SIMTOP) <  $(GRLIB)/bin/runvsim.do

vsim-launch: scripts modelsim
	@vsim -quiet $(SIMTOP).mpf

vsim-unisim: modelsim
	vcom -quiet -explicit -work unisim $(UNISIM)

vsim-simprim: modelsim
	vcom -quiet -explicit -work simprim -ignorevitalerrors $(SIMPRIM)

vsim-clean:
	-rm -rf modelsim transcript *.mti stdout.log vsim.wlf \
	$(SIMTOP).mpf.bak $(SIMTOP).mti *.mpf

vsim-fix:
	cat make.work | sed 's/\([a-zA-Z]\)\(:\\\)/\/\1\//'  > make.work2
	mv make.work2 make.work

#########   GHDL targets   ############

ghdl $(SIMTOP): make.ghdl
	make -f make.ghdl GHDLFLAGS="--workdir=gnu/work --work=work `cat ghdl.path`"

make.ghdl: compile.ghdl
	-rm -rf gnu
	make -f tmpmake.ghdl ghdl
	$(GHDLE) $(VHDLOPT) --workdir=gnu/work --work=work `cat ghdl.path` $(SIMTOP)
	$(GHDLM) $(VHDLOPT) --workdir=gnu/work --work=work `cat ghdl.path` $(SIMTOP) > make.ghdl
	cat tmpmake.ghdl >> make.ghdl

ghdl-run ghdl-launch: $(TOP)
	./$(SIMTOP)

ghdl-clean:
	-rm -rf gnu $(SIMTOP) make.ghdl

#########   NcSim targets   ############

ncsim: xncsim/done
	ncupdate $(SIMTOP)

ncsim-run: ncsim
	ncsim $(SIMTOP)

ncsim-launch: ncsim
	ncsim -gui $(SIMTOP)&

xncsim xncsim/done : compile.ncsim
	-rm -rf xncsim
	make -f make.ncsim
	touch xncsim/done

ncsim-clean:
	-rm -rf xncsim nc*.log ncsim.key

#########   Lattice ISE targets   ############

isp-synp: $(TOP)_synplify.prj synplify/$(TOP).edf
	$(GRLIB)/bin/route_lattice $(TOP) $(UCF) $(PART) synplify $(ISPLIB) $(ISPPACKAGE) $(BITGEN)

isp-prec: $(TOP)_precision.prj precision/$(TOP).edf
	$(GRLIB)/bin/route_lattice $(TOP) $(UCF) $(PART) precision $(ISPLIB) $(ISPPACKAGE) $(BITGEN)

isp-launch-synp: $(TOP)_synplify.prj synplify/$(TOP).edf
	projnav ./$(TOP).syn

isp-launch-prec: $(TOP)_precision.prj precision/$(TOP).edf
	projnav ./$(TOP)_precision.syn

isp-prom:
	synsvf $(PROMGENPAR)
isp-clean:
	-rm -rf $(TOP).dir *.jid *.alt *.lci *.mt *.nc1 *.nc2 *.p?t \
	*.err compxlib.cfg *.jhd *.lct $(TOP).log *.ngy *.prf  *.pt *.rev \
	*.syn *.t2b *.tcm *.tcp *.tw1 $(TOP).tcl *.sty *.svl *.env fonts.dir \
	$(TOP)_tcl.ini



#########   Xilinx ISE targets   ############

ise: $(TOP).ngc
	$(GRLIB)/bin/route_ngc $(TOP) $(UCF) $(DEVICE) $(EFFORT) $(BITGEN) $(GRLIB)/netlists/xilinx/$(TECHNOLOGY)

ise-synp: $(TOP)_synplify.prj synplify/$(TOP).edf
	$(GRLIB)/bin/route $(TOP) $(UCF) $(DEVICE) $(EFFORT) $(BITGEN) synplify \
	$(GRLIB)/netlists/xilinx/$(TECHNOLOGY) $(ISEMAPOPT)

ise-prec: $(TOP).psp precision/$(TOP).edf
	$(GRLIB)/bin/route $(TOP) $(UCF) $(DEVICE) $(EFFORT) $(BITGEN) precision \
	$(GRLIB)/netlists/xilinx/$(TECHNOLOGY)  $(ISEMAPOPT)

ise-launch8 xst-launch: $(TOP).npl $(TOP)_ise.tcl
	ise $(TOP).npl>& ise.err&

ise-launch : $(TOP).ise
	ise $(TOP).ise 

ise-launch-synp: $(TOP).npl $(TOP)_synplify.prj synplify/$(TOP).edf $(TOP)_synplify.prj
	ise $(TOP)_synplify.npl>& ise.err&

$(TOP).xst: compile.xst
	@touch $(TOP).xst; rm $(TOP).xst
	@for i in $(VHDLSYNFILES); do $(GRLIB)/bin/xstvhdl $$i >> $(TOP).xst ; done
#	@for i in $(VERILOGSYNFILES); do $(GRLIB)/bin/xstverilog $ii >> $(TOP).xst; done
	@$(GRLIB)/bin/xstrun $(TOP) $(TOP).vhd  $(DEVICE) $(XSTOPT) -sd $(GRLIB)/netlists/xilinx/$(TECHNOLOGY)/xst >> $(TOP).xst
	@echo  $(TOP).xst

ise-xstmod :
	$(GRLIB)/bin/xstmod $(CORE) $(CORE).vhd $(DEVICE) vhdl  > tmp.xst
	xst -ifn tmp.xst

$(TOP).bit: $(TOP).ngc
	$(GRLIB)/bin/route_ngc $(TOP) $(UCF) $(DEVICE) $(EFFORT) $(BITGEN) $(GRLIB)/netlists/xilinx/$(TECHNOLOGY)

ise-map xst-map ise-xst xst: $(TOP).ngc

$(TOP).ngc: $(TOP).xst $(VHDLSYNFILES) $(VERILOGSYNFILES) compile.xst
	-rm -rf xst
	xst -ifn compile.xst
	xst -ifn $(TOP).xst

$(TOP).ise: $(TOP)_ise.tcl
	xtclsh $(TOP)_ise.tcl

ise-prom:
ifeq ("$(PROMGENPAR)","")
	@echo "not prom programming support for this board"
	@exit 1
else
	promgen $(PROMGENPAR)
	cp $(TOP).bit $(BOARD).bit
	cp $(TOP).msk $(BOARD).msk
endif

ise-cp-ref:
	cp bitfiles/*.* .

ise-prog-prom: ise-prom
	impact -batch $(GRLIB)/boards/$(BOARD)/prom.cmd

ise-prog-prom-usb: ise-prom
	impact -batch $(GRLIB)/boards/$(BOARD)/prom-usb.cmd

ise-prog-prom-ref: ise-cp-ref ise-prom
	impact -batch $(GRLIB)/boards/$(BOARD)/prom.cmd

ise-prog-prom-ref-usb: ise-cp-ref ise-prom
	impact -batch $(GRLIB)/boards/$(BOARD)/prom-usb.cmd

ise-prog-fpga:
	cp $(TOP).bit $(BOARD).bit
	cp $(TOP).msk $(BOARD).msk
	impact -batch $(GRLIB)/boards/$(BOARD)/fpga.cmd

ise-prog-fpga-usb:
	cp $(TOP).bit $(BOARD).bit
	cp $(TOP).msk $(BOARD).msk
	impact -batch $(GRLIB)/boards/$(BOARD)/fpga-usb.cmd


ise-prog-fpga-ref: ise-cp-ref
	cp $(TOP).bit $(BOARD).bit
	cp $(TOP).msk $(BOARD).msk
	impact -batch $(GRLIB)/boards/$(BOARD)/fpga.cmd

ise-prog-fpga-ref-usb: ise-cp-ref
	cp $(TOP).bit $(BOARD).bit
	cp $(TOP).msk $(BOARD).msk
	impact -batch $(GRLIB)/boards/$(BOARD)/fpga-usb.cmd

ise-clean xst-clean:
	-rm -rf xst *.srp xstmods *.twr *.pad _impact* coregen.log \
	tmp.xst *.ngc __projnav* *.stx *.lso *.dhp automake.log \
	$(TOP).prj  $(TOP)_vhdl.prj  coregen* *.bit *.bgn *.bld \
	*.cmd_log *.ll *.mrp *.msk *.ncd *.ngd *.syr *.xpi *.csv \
	*pad.txt *.ngm *.lst *.drc *.par *.pcf *.ngo *.mcs *.prm \
	*.sig *.rba *.rbb *.rbd *.rbt *.msd _ngo _impact* stdout.log \
	ngd2vhdl.log _xmsgs tmp.txt $(TOP).unroutes $(TOP)_usage.xml *.cfi \
	$(TOP).ise* $(TOP).npl* xlnx_auto_0* *.xrpt *.ptwx $(TOP)_xdb \
	$(TOP)_summary.html $(TOP).restore $(TOP).ntrc_log $(TOP).twx \
	$(TOP)_map.map $(TOP).ngr 

#########   Altera Quartus targets   ############

quartus:
	-@case $(TECHNOLOGY) in \
	CYCLONEII) \
		cp  $(GRLIB)/netlists/altera/cyclone2/*.vqm . ;;\
	CYCLONEIII) \
		cp  $(GRLIB)/netlists/altera/cyclone3/*.vqm . ;;\
	STRATIXII) \
		cp  $(GRLIB)/netlists/altera/stratix2/*.vqm . ;;\
	esac
	make quartus-map quartus-route

quartus-synp:  $(TOP)_synplify.prj synplify/$(TOP).edf
	-@case $(TECHNOLOGY) in \
	CYCLONEII) \
		cp  $(GRLIB)/netlists/altera/cyclone2/*.vqm . ;;\
	CYCLONEIII) \
		cp  $(GRLIB)/netlists/altera/cyclone3/*.vqm . ;;\
	STRATIXII) \
		cp  $(GRLIB)/netlists/altera/stratix2/*.vqm . ;;\
	esac
	@-cp synplify/*.hex .
	$(QUARTUS_MAP) --import_settings_files=on  --export_settings_files=off $(TOP)_synplify -c $(TOP)_synplify
	$(QUARTUS_FIT) --import_settings_files=off --export_settings_files=off $(TOP)_synplify -c $(TOP)_synplify
	$(QUARTUS_ASM) --import_settings_files=off --export_settings_files=off $(TOP)_synplify -c $(TOP)_synplify
	$(QUARTUS_TAN) --import_settings_files=off --export_settings_files=off $(TOP)_synplify -c $(TOP)_synplify --timing_analysis_only

quartus-launch: $(TOP).qsf
	-@case $(TECHNOLOGY) in \
	CYCLONEII) \
		cp  $(GRLIB)/netlists/altera/cyclone2/*.vqm . ;;\
	CYCLONEIII) \
		cp  $(GRLIB)/netlists/altera/cyclone3/*.vqm . ;;\
	STRATIXII) \
		cp  $(GRLIB)/netlists/altera/stratix2/*.vqm . ;;\
	esac
	quartus  $(TOP).qpf

quartus-launch-synp:  $(TOP)_synplify.prj synplify/$(TOP).edf
	-@case $(TECHNOLOGY) in \
	CYCLONEII) \
		cp  $(GRLIB)/netlists/altera/cyclone2/*.vqm . ;;\
	CYCLONEIII) \
		cp  $(GRLIB)/netlists/altera/cyclone3/*.vqm . ;;\
	STRATIXII) \
		cp  $(GRLIB)/netlists/altera/stratix2/*.vqm . ;;\
	esac
	quartus $(TOP)_synplify.qpf

quartus-map: $(TOP).qsf
	-@case $(TECHNOLOGY) in \
	CYCLONEII) \
		cp  $(GRLIB)/netlists/altera/cyclone2/*.vqm . ;;\
	CYCLONEIII) \
		cp  $(GRLIB)/netlists/altera/cyclone3/*.vqm . ;;\
	STRATIXII) \
		cp  $(GRLIB)/netlists/altera/stratix2/*.vqm . ;;\
	esac
	$(QUARTUS_MAP) --import_settings_files=on  --export_settings_files=off $(TOP) -c $(TOP)

quartus-route: $(TOP).qsf
	$(QUARTUS_FIT) --import_settings_files=off --export_settings_files=off $(TOP) -c $(TOP)
	$(QUARTUS_ASM) --import_settings_files=off --export_settings_files=off $(TOP) -c $(TOP)
	$(QUARTUS_TAN) --import_settings_files=off --export_settings_files=off $(TOP) -c $(TOP) --timing_analysis_only

quartus-prog-fpga:
	$(QUARTUS_PGM) -c $(ALTCABLE) -m JTAG -o p\;$(TOP).sof

quartus-prog-fpga-ref:
	cp bitfiles/$(TOP).sof $(TOP)_ref.sof
	$(QUARTUS_PGM) -c $(CABLE) -m JTAG -o p\;$(TOP)_ref.sof

quartus-srec:
	$(QUARTUS_PGM)

quartus-clean:
	-rm -rf db *.syr *.qws automake.log dumpdata.txt \
	*.rpt *.done *.eqn *.pof *.summary *.ttf *.pin *.sof \
	*.jam *.jbc cmp_state.ini simulation undo_redo.txt *.vqm *.qdf \
	*.csf *.psf *.quartus *.smsg .undefinedlib .jaguarc .unorderedFilePath

########   Synplify targets   ########################

synplify synplify-map: $(TOP)_synplify.prj synplify/$(TOP).edf

synplify-launch: $(TOP)_synplify.prj
	$(SYNPLIFY) $(TOP)_synplify.prj&
	-@mkdir synplify>& tmp.err; touch synplify/dummy.mif
	-@mv synplify/*.mif .

synplify/$(TOP).edf: $(VHDLSYNFILES) $(VERILOGSYNFILES)
	$(SYNPLIFY) -batch $(TOP)_synplify.prj
	@touch synplify/dummy.mif
	-@mv synplify/*.mif .

$(TOP)_synplify.prj: compile.synp
	@echo source compile.synp > $(TOP)_synplify.prj
	@for i in $(VHDLSYNFILES); do echo add_file "-vhdl -lib work" $$i >> $(TOP)_synplify.prj; done
#	@for i in $(VERILOGSYNFILES); do echo add_file "-verilog -lib work" $ii >> $(TOP)_synplify.prj; done
	@for i in $(SDCFILE); do echo add_file "-constraint " $$i >> $(TOP)_synplify.prj; done
	@cat $(GRLIB)/bin/synplify.prj | sed -e s/TOP/$(TOP)/ \
	-e s/TECHNOLOGY/$(TECHNOLOGY)/ \
	-e s/PART/$(PART)/ -e s/SPEED/$(SPEED)/ -e s/SYNFREQ/$(SYNFREQ)/ >> $(TOP)_synplify.prj
ifneq ("$(PACKAGE)","")
	@echo set_option -package $(PACKAGE) >> $(TOP)_synplify.prj
endif
ifneq ("$(SYNPVLOGDEFS)","")
	@echo set_option -hdl_define -set \"$(SYNPVLOGDEFS)\" >> $(TOP)_synplify.prj
endif
ifneq ("$(SYNPVLOGINC)","")
	@echo set_option -include_path \"$(SYNPVLOGINC)\" >> $(TOP)_synplify.prj
endif
	@echo $(SYNPOPT) >> $(TOP)_synplify.prj
	@echo impl -active \"synplify\" >> $(TOP)_synplify.prj
	@echo  $(TOP)_synplify.prj

synplify-clean:
	-rm -rf synplify *.prd stdout.log *.mif syntmp.* synplify_* \
	$(TOP).map $(TOP)_summary.xml

########   Precision targets   ########################

precision precision-map: $(TOP)_precision.tcl $(TOP).psp precision/$(TOP).edf

$(TOP).psp: $(TOP)_precision.tcl
	$(PRECISION) -shell -file $(TOP)_precision.tcl

precision-launch: $(TOP).psp
	$(PRECISION)  -project $(TOP).psp

precision/$(TOP).edf: $(TOP)_precision.tcl  $(VHDLSYNFILES) $(VERILOGSYNFILES)
	$(PRECISION) -shell -file $(TOP)_precrun.tcl

precision-clean:
	-rm -rf *.psp stdout.log prec.log  $(TOP)_prec* precision* $(TOP)_temp*

#########   Actel Libero targets    ############################

libero-launch : $(TOP)_libero.prj
	$(LIBERO) $(TOP)_libero.prj

#########   Actel Designer targets    ############################

actel: $(TOP)_synplify.prj synplify/$(TOP).edf $(TOP)_designer.tcl
	-mkdir ./actel
	$(DESIGNER) script:$(TOP)_designer.tcl

actel-launch actel-launch-synp: $(TOP)_synplify.prj synplify/$(TOP).edf $(TOP)_designer.tcl $(TOP).adb
	$(DESIGNER) $(TOP).adb &

$(TOP).adb:
	$(DESIGNER) script:$(TOP)_designer_act.tcl

$(TOP)_designer.tcl:
	@echo "new_design -name \""$(TOP)\"" -family \""$(TECHNOLOGY)\"" " > $(TOP)_designer.tcl
ifeq ("$(DESIGNER_RADEXP)","")
	@echo "set_device -die \""$(PART)\"" -package \""$(DESIGNER_PINS) $(DESIGNER_PACKAGE)\"" -speed \""$(SPEED)\"" -voltage \"1.5\" -iostd \"LVTTL\" -jtag \"yes\" -probe \"yes\" -trst \"yes\" -temprange \""$(DESIGNER_VOLTAGE)\"" -voltrange \""$(DESIGNER_VOLTAGE)\"" " >> $(TOP)_designer.tcl
else
	@echo "set_device -die \""$(PART)\"" -package \""$(DESIGNER_PINS) $(DESIGNER_PACKAGE)\"" -speed \""$(SPEED)\"" -voltage \"1.5\" -iostd \"LVTTL\" -jtag \"yes\" -probe \"yes\" -trst \"yes\" -temprange \""$(DESIGNER_VOLTAGE)\"" -voltrange \""$(DESIGNER_VOLTAGE)\"" -radexp \""$(DESIGNER_RADEXP)\"" " >> $(TOP)_designer.tcl
endif
	@echo "if {[file exist "$(TOP).pdc"]} {" >> $(TOP)_designer.tcl
	@echo "import_source -format \"edif\" -edif_flavor \"GENERIC\" " -merge_physical \"no\" -merge_timing \"no\"" {"synplify/$(TOP)".edf"} -format \"pdc\" -abort_on_error \"no\" {"$(TOP).pdc"} >> $(TOP)_designer.tcl
	@echo "} else {" >> $(TOP)_designer.tcl
	@echo "import_source -format \"edif\" -edif_flavor \"GENERIC\" " -merge_physical \"no\" -merge_timing \"no\"" {"synplify/$(TOP)".edf"} >> $(TOP)_designer.tcl
	@echo "}" >> $(TOP)_designer.tcl
	@cp $(TOP)_designer.tcl $(TOP)_designer_act.tcl
	@echo "save_design {"$(TOP).adb"}" >> $(TOP)_designer_act.tcl
	@echo "compile -combine_register 1" >> $(TOP)_designer.tcl
	@echo "if {[file exist "$(PDC)"]} {" >> $(TOP)_designer.tcl
	@echo "   import_aux -format \"pdc\" -abort_on_error \"no\" {"$(PDC)"}" >> $(TOP)_designer.tcl
	@echo "   pin_commit" >> $(TOP)_designer.tcl
	@echo "} else {" >> $(TOP)_designer.tcl
	@echo "   puts \"WARNING: No PDC file imported.\"" >> $(TOP)_designer.tcl
	@echo "}" >> $(TOP)_designer.tcl
ifeq ("$(PDC_EXTRA)","")
else
	@echo "if {[file exist "$(PDC_EXTRA)"]} {" >> $(TOP)_designer.tcl
	@echo "   import_aux -format \"pdc\" -abort_on_error \"no\" {"$(PDC_EXTRA)"}" >> $(TOP)_designer.tcl
	@echo "   pin_commit" >> $(TOP)_designer.tcl
	@echo "} else {" >> $(TOP)_designer.tcl
	@echo "   puts \"WARNING: No PDC_EXTRA file imported.\"" >> $(TOP)_designer.tcl
	@echo "}" >> $(TOP)_designer.tcl
endif

	@echo "if {[file exist "$(SDC)"]} {" >> $(TOP)_designer.tcl
	@echo "   import_aux -format \"sdc\" -merge_timing \"no\" {"$(SDC)"}" >> $(TOP)_designer.tcl
	@echo "} else {" >> $(TOP)_designer.tcl
	@echo "   puts \"WARNING: No SDC file imported.\"" >> $(TOP)_designer.tcl
	@echo "}" >> $(TOP)_designer.tcl
ifeq ("$(SDC_EXTRA)","")
else
	@echo "if {[file exist "$(SDC_EXTRA)"]} {" >> $(TOP)_designer.tcl
	@echo "   import_aux -format \"sdc\" -merge_timing \"yes\" {"$(SDC_EXTRA)"}" >> $(TOP)_designer.tcl
	@echo "} else {" >> $(TOP)_designer.tcl
	@echo "   puts \"WARNING: No SDC_EXTRA file imported.\"" >> $(TOP)_designer.tcl
	@echo "}" >> $(TOP)_designer.tcl
endif
	@echo "save_design {"$(TOP).adb"}" >> $(TOP)_designer.tcl
	@echo "report -type status {./actel/report_status_pre.log}" >> $(TOP)_designer.tcl
ifeq ("$(TECHNOLOGY)","AXCELERATOR")
	@echo "layout -effort_level 5 -timing_driven -incremental \"OFF\"" >> $(TOP)_designer.tcl
else
	@echo "layout -timing_driven -incremental \"OFF\"" >> $(TOP)_designer.tcl
endif
	@echo "save_design {"$(TOP).adb"}" >> $(TOP)_designer.tcl
	@echo "backannotate -dir {./actel} -name \"$(TOP)\" -format \"SDF\" -language \"VHDL93\" -netlist"  >> $(TOP)_designer.tcl
	@echo "report -type \"timer\" -sortby \"actual\" -maxpaths \"100\" -case \"worst\" -path_selection \"critical\" -setup_hold \"on\" -expand_failed \"off\" -clkpinbreak \"off\" -clrpinbreak \"on\" -latchdatapinbreak \"off\" -slack  {./actel/report_timer_worst.txt}" >> $(TOP)_designer.tcl
	@echo "report -type \"timer\" -sortby \"actual\" -maxpaths \"100\" -case \"best\"  -path_selection \"critical\" -setup_hold \"on\" -expand_failed \"off\" -clkpinbreak \"off\" -clrpinbreak \"on\" -latchdatapinbreak \"off\" -slack  {./actel/report_timer_best.txt}" >> $(TOP)_designer.tcl
	@echo "report -type \"timer\" -analysis \"max\" -print_summary \"yes\" -use_slack_threshold \"no\" -print_paths \"yes\" -max_paths 100 -max_expanded_paths 5 -include_user_sets \"yes\" -include_pin_to_pin \"yes\" -select_clock_domains \"no\"  {./actel/report_timer_max.txt}" >> $(TOP)_designer.tcl
	@echo "report -type \"timer\" -analysis \"min\" -print_summary \"yes\" -use_slack_threshold \"no\" -print_paths \"yes\" -max_paths 100 -max_expanded_paths 5 -include_user_sets \"yes\" -include_pin_to_pin \"yes\" -select_clock_domains \"no\"  {./actel/report_timer_min.txt}" >> $(TOP)_designer.tcl
	@echo "report -type \"pin\" -listby \"name\" {./actel/report_pin_name.log}" >> $(TOP)_designer.tcl
	@echo "report -type \"pin\" -listby \"number\" {./actel/report_pin_number.log}" >> $(TOP)_designer.tcl
	@echo "report -type \"datasheet\" {./actel/report_datasheet.txt}" >> $(TOP)_designer.tcl
ifeq ("$(TECHNOLOGY)","AXCELERATOR")
	@echo "export -format \"AFM-APS2\" -trstb_pullup \"yes\" -global_set_fuse \"reset\" -axprg_set_algo \"UMA\" {./actel/$(TOP).afm}"  >> $(TOP)_designer.tcl
	@echo "export -format \"prb\" {./actel/$(TOP).prb}"  >> $(TOP)_designer.tcl
else
	@echo "export -format \"pdb\" -feature \"prog_fpga\" -io_state \"Tri-State\" {./actel/$(TOP).pdb}"  >> $(TOP)_designer.tcl
endif
	@echo "export -format log -diagnostic {./actel/report_log.log}" >> $(TOP)_designer.tcl
	@echo "report -type status {./actel/report_status_post.log}" >> $(TOP)_designer.tcl
	@echo "save_design {"$(TOP).adb"}" >> $(TOP)_designer.tcl

actel-clean:
	-rm -rf *.adb report*.log ./actel hdl constraint \
	actgen constraint designer package phy_synthesis simulation \
	smartgen stimulus synthesis viewdraw libero x $(TOP)_libero.prj \
	libero_sim_files libero_syn_files coreconsole libero_simlist \
	libero_synlist libero.do component *.pdb *.pdb.depends *.stp \
	*.sdb *_layout.log *.dtf

############  Synopsys DC targets   ########################

dc-launch: $(TOP)_dc.tcl
	-mkdir synopsys
	design_compiler&

dc: $(TOP)_dc.tcl
	-mkdir synopsys
	dc_shell-xg-t -f $(DCSCRIPT)

$(TOP)_dc.tcl: compile.dc
	@cp $(GRLIB)/bin/top.dc $(TOP)_dc.tcl
#	@for i in $(VERILOGSYNFILES); do echo "analyze -f verilog -library work" $$i >> $(TOP)_dc.tcl; done
	@for i in $(VHDLSYNFILES); do echo "analyze -f VHDL -library work" $$i >> $(TOP)_dc.tcl; done
	@echo elaborate $(TOP) >> $(TOP)_dc.tcl
	@echo  $(TOP)_dc.tcl

dc-clean:
	-rm -rf synopsys view_command.log command.log dumpdata.txt filenames.log \
	dc.log dwsvf* alib* $(TOP)_dc.tcl

############  Cadence RTL Compiler   ########################

rc: $(TOP).rc
	-mkdir rtlc
	rc -files $(RCSCRIPT)

$(TOP).rc: compile.rc
	@cp $(GRLIB)/bin/top.rc $(TOP).rc
	@for i in $(VHDLSYNFILES); do echo "read_hdl -vhdl -lib work" $$i >> $(TOP).rc; done
#	@for i in $(VERILOGSYNFILES); do echo "read_hdl " $$i >> $(TOP).rc; done
	@echo elaborate $(TOP) >> $(TOP).rc
	@echo  $(TOP).rc

rc-clean:
	-rm -rf rtlc rc.log rc.cmd

########## Generation of compile scripts ###############

scripts: compile.dc compile.synp compile.son compile.vsim compile.asim compile.xst compile.ncsim compile.rc \
	$(TOP)_synplify.prj $(TOP)_dc.tcl $(TOP).rc $(TOP).xst $(TOP).npl $(TOP)_ise.tcl $(TOP).qsf \
	$(TOP)_designer.tcl $(TOP)_libero.prj

verilog.txt $(TOP)_libero.prj compile.dc compile.synp compile.son compile.vsim compile.asim compile.xst compile.ncsim compile.rc compile.ghdl $(TOP).npl $(TOP)_ise.tcl $(TOP).qsf $(TOP)_precision.tcl :
	@touch libs.txt; rm libs.txt;
	@touch tmp.son; rm tmp.son;
	@cp $(GRLIB)/bin/cds.lib cds.lib; touch hdl.var;
	@for i in vsim synp xst dc ncsim ghdl rc son; do \
	    touch compile.$$i; rm compile.$$i ; \
	done
	@printf "\tmkdir xncsim\n" > compile.ncsim
	@echo sh mkdir synopsys > compile.dc
	@echo vlib modelsim > libs.do
	@echo ""  > alibs.do
	@printf "\tmkdir gnu\n" > compile.ghdl
	@echo set_attribute input_pragma_keyword \"cadence synopsys get2chip g2c fast ambit pragma\" > compile.rc
	@echo "[Library]" > modelsim.ini;
	@echo "" > tmp.mpf;
	@echo "" > verilog.txt;
	@echo [Device] > $(TOP).lct
	@echo Family = $(ISPLIB)\; >> $(TOP).lct
	@echo PartNumber = $(PART)$(SPEED)$(PACKAGE)\; >> $(TOP).lct
	@echo Package = $(ISPPACKAGE)\; >> $(TOP).lct
	@echo PartType = $(PART)\; >> $(TOP).lct
	@echo Speed = $(SPEED)\; >> $(TOP).lct
	@echo Operating_condition = COM\; >> $(TOP).lct
	@echo Status = Production\; >> $(TOP).lct
	@echo JDF B > $(TOP).syn
	@echo PROJECT $(TOP) >> $(TOP).syn
	@echo DESIGN $(TOP) Normal >> $(TOP).syn
	@echo DEVKIT $(PART)$(SPEED)$(PACKAGE) >> $(TOP).syn
	@echo ENTRY EDIF >> $(TOP).syn
	@echo MODULE ./synplify/$(TOP).edf >> $(TOP).syn
	@echo MODSTYLE $(TOP) Normal >> $(TOP).syn
	@echo JDF G > $(TOP).npl
	@echo PROJECT $(TOP) >> $(TOP).npl
	@echo project new $(TOP).ise > $(TOP)_ise.tcl
	@echo DESIGN $(TOP) >> $(TOP).npl
	@echo DEVFAM $(TECHNOLOGY) >> $(TOP).npl
	@echo project set family \"$(ISETECH)\" >> $(TOP)_ise.tcl
	@echo DEVICE $(PART) >> $(TOP).npl
	@echo project set device $(PART) >> $(TOP)_ise.tcl
	@echo DEVSPEED $(SPEED) >> $(TOP).npl
	@echo project set speed $(SPEED) >> $(TOP)_ise.tcl
	@echo DEVPKG $(PACKAGE) >> $(TOP).npl
	@echo project set package $(PACKAGE) >> $(TOP)_ise.tcl
	@cp $(TOP).npl $(TOP)_synplify.npl
	@echo DEVTOPLEVELMODULETYPE HDL >> $(TOP).npl
	@echo DEVTOPLEVELMODULETYPE EDIF >> $(TOP)_synplify.npl
	@cat  $(GRLIB)/bin/def.npl >> $(TOP).npl
	@cat  $(GRLIB)/bin/def.npl >> $(TOP)_synplify.npl
	@touch tmp.npl; rm tmp.npl
	@for i in $(VHDLSYNFILES); do \
	   echo SOURCE $$i >> tmp.npl; \
	   echo xfile add \"$$i\" -lib_vhdl work >> $(TOP)_ise.tcl; \
	done; \
	echo xfile add \"$(UCF)\" >> $(TOP)_ise.tcl; \
	cp $(GRLIB)/bin/quartus.qsf_head $(TOP).qsf; \
	cp $(GRLIB)/bin/quartus.qsf_head $(TOP)_synplify.qsf; \
	echo "set_global_assignment -name VQM_FILE" "synplify/$(TOP).edf" >> $(TOP)_synplify.qsf; \
	if test -r "$(QSF)"; then cat $(QSF) >> $(TOP)_synplify.qsf; fi; \
	cp $(GRLIB)/bin/quartus.qpf $(TOP).qpf; \
	cp $(TOP).qpf $(TOP)_synplify.qpf; \
	echo PROJECT_REVISION = $(TOP) >> $(TOP).qpf; \
	echo PROJECT_REVISION = $(TOP)_synplify >> $(TOP)_synplify.qpf; \
	echo KEY LIBERO \"8.1\" > $(TOP)_libero.prj; \
	echo KEY CAPTURE \"8.1.0.32\" >> $(TOP)_libero.prj; \
	echo KEY HDLTechnology \"VHDL\" >> $(TOP)_libero.prj; \
	echo KEY VendorTechnology_Family \"$(MGCTECHNOLOGY)\" >> $(TOP)_libero.prj; \
	echo KEY VendorTechnology_Die \"$(LIBERO_DIE)\" >> $(TOP)_libero.prj; \
	echo KEY VendorTechnology_Package \"$(LIBERO_PACKAGE)\" >> $(TOP)_libero.prj; \
	echo KEY ProjectLocation \"\.\" >> $(TOP)_libero.prj; \
	echo KEY SimulationType \"VHDL\" >> $(TOP)_libero.prj; \
	echo KEY Vendor \"Actel\" >> $(TOP)_libero.prj; \
	echo KEY ActiveRoot \"$(TOP)\"	 >> $(TOP)_libero.prj; \
	echo LIST REVISIONS >> $(TOP)_libero.prj; \
	echo VALUE=\"Impl1\",NUM=1 >> $(TOP)_libero.prj; \
	echo CURREV=1 >> $(TOP)_libero.prj; \
	echo ENDLIST >> $(TOP)_libero.prj; \
	echo LIST FileManager > libero_syn_files ; \
	echo LIST ExcludePackageForSynthesis > libero_sim_files; \
	echo LIST $(TOP) >> libero_sim_files; \
	echo LIST \"ideSYNTHESIS\" > libero_synlist; \
	echo USE_LIST=TRUE >> libero_synlist; \
	echo FILELIST >> libero_synlist; \
	echo LIST \"ideSIMULATION\" > libero_simlist; \
	echo USE_LIST=TRUE >> libero_simlist; \
	echo FILELIST >> libero_simlist; \
	ppath="gnu"; nfiles=0; xfiles=8;\
	cat $(GRLIB)/bin/sonata1.sws > sonata.sws; \
	echo "open_project ./$(TOP).psp"> $(TOP)_precrun.tcl; \
	echo compile >> $(TOP)_precrun.tcl; echo synthesize >> $(TOP)_precrun.tcl; \
	echo save_impl >> $(TOP)_precrun.tcl; \
	echo "new_project -name $(TOP) -folder . -createimpl_name precision"> $(TOP)_precision.tcl; \
	echo "setup_design -manufacturer $(MANUFACTURER) -family $(MGCTECHNOLOGY) -part $(MGCPART) -package $(MGCPACKAGE) -speed $(SPEED)" >> $(TOP)_precision.tcl; \
	echo "set_input_dir ." >> $(TOP)_precision.tcl ;\
	echo "Scanning libraries" ; \
	if (test -r $(EXTRALIBS)/libs.txt); then extralib=$(EXTRALIBS)/libs.txt; else \
	extralib=$(GRLIB)/bin/libs.txt; fi; \
	for j in grlib $(XTECHLIBS) `cat $(GRLIB)/lib/libs.txt  $(GRLIB)/lib/*/libs.txt $$extralib` $(LIBADD) work ; do \
	  bn=`basename $$j` ; \
          ppath="$$ppath -Pgnu/$$bn"; \
	  k=$(GRLIB)/lib/$$j; \
	  if test -r $$k; then xxx=0; else k=$(EXTRALIBS)/$$j; fi;\
	  if (test $$bn = "techmap"); then tdirs="$(TECHLIBS) maps"; \
	  else tdirs=""; fi; \
	  case $$bn in $(XLIBSKIP) )\
	    ;; \
	  *) \
	    if (test -r $$k/dirs.txt); then \
	        echo DEFINE $$bn xncsim/$$bn "" >> cds.lib; \
	        printf "\tmkdir gnu/$$bn\n" >> compile.ghdl; \
                echo -n $$bn "" >> libs.txt; echo $$bn = modelsim/$$bn >> modelsim.ini; \
	        echo vlib modelsim/$$bn "" >> libs.do; \
	        echo alib $$bn $$bn.lib "" >> alibs.do; \
	      	printf "\tmkdir xncsim/$$bn\n" >> compile.ncsim; \
	  	if (test $$bn != "dw02"); then \
	          echo sh mkdir synopsys/$$bn "" >> compile.dc; \
	          echo define_design_lib $$bn -path synopsys/$$bn "" >> compile.dc; \
		fi ; \
	        case $$bn in \
		work) \
	          echo " "sonata "=" sonata/sonata.sym >> sonata.sws; \
		  set bn = "sonata"; \
	    	  echo "[library]" >> tmp.son; \
	    	  echo name = sonata >> tmp.son; \
	    	  echo toplevel = $(SIMTOP) >> tmp.son; \
	    	  echo "  [options]" >>  tmp.son; \
	    	  echo "   [booloption]" >>  tmp.son; \
	    	  echo "    name   = -autoorder" >>  tmp.son; \
	    	  echo "    value  = 0" >>  tmp.son; \
	    	  echo "    invert = 0" >>  tmp.son; \
	    	  echo "   []" >>  tmp.son; \
	    	  echo "  []" >>  tmp.son;; \
	        *) \
	          echo " "$$bn "=" sonata/$$bn.sym >> sonata.sws; \
	    	  echo "[library]" >> tmp.son; \
	    	  echo name = $$bn >> tmp.son; \
	    	  echo "  [options]" >>  tmp.son; \
	    	  echo "   [booloption]" >>  tmp.son; \
	    	  echo "    name   = -autoorder" >>  tmp.son; \
	    	  echo "    value  = 0" >>  tmp.son; \
	    	  echo "    invert = 0" >>  tmp.son; \
	    	  echo "   []" >>  tmp.son; \
	    	  echo "  []" >>  tmp.son;; \
	        esac; \
		case $$bn in $(XSTLIBSKIP) )\
		  uu=0;; \
		*) \
	          echo SUBLIB $$bn VhdlLibrary vhdl >> tmp.npl; \
	          echo lib_vhdl new $$bn >> $(TOP)_ise.tcl;; \
	        esac; \
	        echo -n "  "$$bn":"; \
	      for l in `cat $$k/dirs.txt` $$tdirs ; do \
	        case $$l in $(XDIRSKIP) )\
		  ;; \
		*) \
		  if test -r $$k/$$l; then \
		    echo -n " "$$l; \
		  fi; \
	    	  for i in vlogsyn vhdlsyn vlogsim vhdlsim ; do \
		   m=$$k/$$l/$$i; \
		   if test -r $$m.txt; then \
		    for q in `cat $$m.txt`; do \
	              case $$q in $(XFILESKIP) )\
		        ;; \
		      *) \
		       if test -r $$k/$$l/$$q; then \
			case $$i in \
			vhdlsyn) \
		           echo Project_File_$$nfiles = $$k/$$l/$$q >> tmp.mpf; \
		           echo Project_File_P_$$nfiles = vhdl_novitalcheck 0 file_type VHDL group_id 0 vhdl_nodebug 0 vhdl_1164 1 vhdl_noload 0 vhdl_synth 0 folder {Top Level} last_compile 0 vhdl_disableopt 0 vhdl_vital 0 vhdl_warn1 0 vhdl_warn2 1 vhdl_explicit 0 vhdl_showsource 1 vhdl_warn3 1 vhdl_options {} vhdl_warn4 1 ood 0 vhdl_warn5 0 compile_to $$bn compile_order $$nfiles dont_compile 0 cover_stmt 1 vhdl_use93 93 >> tmp.mpf; \
			   nfiles=`expr $$nfiles + 1`; \
                           printf "\t$(VCOM) $(VHDLOPT) $$bn $$k/$$l/$$q\n" >> compile.vsim; \
                           printf "\t$(ACOM) $(VHDLOPT) $$bn ../../$$k/$$l/$$q\n" >> compile.asim; \
                           printf "\t$(NCVHDL) $(VHDLOPT) $$bn $$k/$$l/$$q\n" >> compile.ncsim; \
		           printf "\t$(GHDL) $(VHDLOPT) --workdir=gnu/$$bn --work=$$bn -P$$ppath $$k/$$l/$$q\n" >> compile.ghdl; \
			   case $$bn in $(XDCLIBSKIP) ) ;; *) \
			    case $$l in $(XDCDIRSKIP) ) ;; *) \
			      case $$q in $(DCSKIP) ) ;; *) \
		                echo $(DCVHDL) $(VHDLOPT) $$bn $$k/$$l/$$q >> compile.dc; \
		                echo $(RTLCVHDL) $(VHDLOPT) $$bn $$k/$$l/$$q >> compile.rc; \
			      esac; \
			    esac; \
			   esac; \
			   case $$bn in $(XSYNPLIBSKIP) )\
				uu=0;; \
			   *) \
			    case $$l in $(XSYNPDIRSKIP) ) ;; *) \
			      case $$q in $(SYNPSKIP) ) ;; *) \
		                echo $(SYNPVHDL) $(VHDLOPT) $$bn $$k/$$l/$$q >> compile.synp;; \
			      esac; \
			    esac; \
			   esac; \
	                   if (test $$bn = "work"); then \
		             printf "\t$(VHDLP) $(VHDLOPT) sonata $$k/$$l/$$q\n" >> compile.son; \
	  		   else \
		             printf "\t$(VHDLP) $(VHDLOPT) $$bn $$k/$$l/$$q\n" >> compile.son; \
			   fi; \
			   echo " [file]" >> tmp.son; \
			   echo "  name" = $$k/$$l/$$q >> tmp.son; \
			   echo " []" >> tmp.son; \
			   case $$bn in $(LIBEROLIBSKIP) )\
				uu=0;; \
			   *) \
			    case $$l in $(LIBERODIRSKIP) ) ;; *) \
			      case $$q in $(LIBEROSKIP) ) ;; *) \
	    		        echo VALUE \"\<project\>/$$k/$$l/$$q,hdl\" >> libero_syn_files; \
	    		        echo VALUE \"\<project\>/$$k/$$l/$$q,hdl\" >> libero_synlist; \
	    		        echo VALUE \"\<project\>/$$k/$$l/$$q,hdl\" >> libero_simlist; \
	  		        echo STATE=\"utd\" >> libero_syn_files; \
	  		        echo LIBRARY=\"$$bn\" >> libero_syn_files; \
	  		        echo ENDFILE >> libero_syn_files;; \
			      esac; \
			    esac; \
			   esac; \
			   case $$bn in $(XSTLIBSKIP) )\
				uu=0;; \
			   *) \
			     case $$l in $(XSTDIRSKIP) )\
				uu=0;; \
			     *) \
			       case $$q in $(XSTSKIP) ) ;; *) \
		                 echo LIBFILE $$k/$$l/$$q $$bn vhdl >> tmp.npl; \
		                 echo xfile add \"$$k/$$l/$$q\" -lib_vhdl $$bn >> $(TOP)_ise.tcl; \
		                 echo $(XSTVHDL) $(VHDLOPT) $$bn -ifn $$k/$$l/$$q >> compile.xst; \
			         xfiles=`expr $$xfiles + 1`;; \
			       esac; \
			     esac; \
			   esac; \
			   case $$bn in $(QUARTUSLIBSKIP) )\
				uu=0;; \
			   *) \
			     case $$l in $(QDIRSKIP) )\
				uu=0;; \
			     *) \
			      case $$q in $(QUARTUSSKIP) ) ;; *) \
		               echo set_global_assignment -name VHDL_FILE $$k/$$l/$$q -library $$bn >> $(TOP).qsf;; \
			      esac; \
			    esac; \
			   esac; \
			   case $$bn in $(PRECLIBSKIP) )\
				uu=0;; \
			   *) \
			     case $$bn in $(PRECDIRSKIP) )\
				uu=0;; \
			     *) \
			      case $$q in $(PRECSKIP) ) ;; *) \
		               echo add_input_file -format VHDL -work $$bn  $$k/$$l/$$q >> $(TOP)_precision.tcl;; \
			      esac; \
			    esac; \
			   esac;; \
			vlogsyn) \
		           echo Project_File_$$nfiles = $$k/$$l/$$q >> tmp.mpf; \
		           echo Project_File_P_$$nfiles = vlog_protect 0 file_type Verilog group_id 0 vlog_1995compat 0 vlog_nodebug 0 folder {Top Level} vlog_noload 0 last_compile 0 vlog_disableopt 0 vlog_hazard 0 vlog_showsource 0 ood 1 compile_to $$bn vlog_upper 0 vlog_options {} compile_order $$nfiles dont_compile 0 >> tmp.mpf; \
			   nfiles=`expr $$nfiles + 1`; \
		           printf "\t$(VLOG) $$bn +incdir+$$k/$$l $$k/$$l/$$q\n" >> compile.vsim; \
		           printf "\t$(ALOG) $$bn ../../$$k/$$l/$$q\n" >> compile.asim; \
		           printf "\t$(NCVLOG) $$bn -INCDIR $$k/$$l $$k/$$l/$$q\n" >> compile.ncsim; \
		           echo $(XSTVLOG) $$bn -ifn $$k/$$l/$$q >> compile.xst; \
			   case $$bn in $(LIBEROLIBSKIP) )\
				uu=0;; \
			   *) \
			    case $$q in $(LIBEROSKIP) ) ;; *) \
	    		      echo VALUE \"\<project\>/$$k/$$l/$$q,hdl\" >> libero_syn_files; \
	    		      echo VALUE \"\<project\>/$$k/$$l/$$q,hdl\" >> libero_synlist; \
	    		      echo VALUE \"\<project\>/$$k/$$l/$$q,hdl\" >> libero_simlist; \
	  		      echo STATE=\"utd\" >> libero_syn_files; \
	  		      echo LIBRARY=\"$$bn\" >> libero_syn_files; \
	  		      echo ENDFILE >> libero_syn_files;; \
			    esac; \
			   esac; \
		           echo $$k/$$l/$$q >> verilog.txt; \
		           echo $(DCVLOG) $$bn $$k/$$l/$$q >> compile.dc; \
		           echo $(RTLCVLOG) $$k/$$l/$$q >> compile.rc; \
		           echo LIBFILE $$k/$$l/$$q $$bn verilog >> tmp.npl; \
		           echo $(SYNPVLOG) $$k/$$l/$$q >> compile.synp; \
		           echo add_input_file -format VERILOG -work $$bn  $$k/$$l/$$q >> $(TOP)_precision.tcl; \
		           echo set_global_assignment -name VERILOG_FILE $$k/$$l/$$q -library $$bn >> $(TOP).qsf;; \
			vhdlsim) \
			   echo " [file]" >> tmp.son; \
			   echo "  name" = $$k/$$l/$$q >> tmp.son; \
			   echo " []" >> tmp.son; \
			   case $$bn in $(LIBEROLIBSKIP) )\
				uu=0;; \
			   *) \
			    case $$q in $(LIBEROSKIP) ) ;; *) \
	    		      echo VALUE \"\<project\>/$$k/$$l/$$q,hdl\" >> libero_sim_files; \
	    		      echo VALUE \"\<project\>/$$k/$$l/$$q,hdl\" >> libero_syn_files; \
	    		      echo VALUE \"\<project\>/$$k/$$l/$$q,hdl\" >> libero_simlist; \
	  		      echo STATE=\"utd\" >> libero_syn_files; \
	  		      echo LIBRARY=\"$$bn\" >> libero_syn_files; \
	  		      echo ENDFILE >> libero_syn_files;; \
			    esac; \
			   esac; \
		           echo Project_File_$$nfiles = $$k/$$l/$$q >> tmp.mpf; \
		           echo Project_File_P_$$nfiles = vhdl_novitalcheck 0 file_type VHDL group_id 0 vhdl_nodebug 0 vhdl_1164 1 vhdl_noload 0 vhdl_synth 0 folder {Top Level} last_compile 0 vhdl_disableopt 0 vhdl_vital 0 vhdl_warn1 0 vhdl_warn2 1 vhdl_explicit 0 vhdl_showsource 1 vhdl_warn3 1 vhdl_options {} vhdl_warn4 1 ood 0 vhdl_warn5 0 compile_to $$bn compile_order $$nfiles dont_compile 0 cover_stmt 1 vhdl_use93 93 >> tmp.mpf; \
			   nfiles=`expr $$nfiles + 1`; \
		           printf "\t$(VCOM) $(VHDLOPT) $$bn $$k/$$l/$$q\n" >> compile.vsim; \
	                   if (test $$bn = "work"); then \
		             printf "\t$(VHDLP) $(VHDLOPT) sonata $$k/$$l/$$q\n" >> compile.son; \
	  		   else \
		             printf "\t$(VHDLP) $(VHDLOPT) $$bn $$k/$$l/$$q\n" >> compile.son; \
			   fi; \
		           printf "\t$(ACOM) $(VHDLOPT) $$bn ../../$$k/$$l/$$q\n" >> compile.asim; \
		           printf "\t$(NCVHDL) $(VHDLOPT) $$bn $$k/$$l/$$q\n" >> compile.ncsim; \
		           printf "\t$(GHDL) $(VHDLOPT) --workdir=gnu/$$bn --work=$$bn -P$$ppath $$k/$$l/$$q\n" >> compile.ghdl;; \
			vlogsim) \
		           echo Project_File_$$nfiles = $$k/$$l/$$q >> tmp.mpf; \
		           echo Project_File_P_$$nfiles = vlog_protect 0 file_type Verilog group_id 0 vlog_1995compat 0 vlog_nodebug 0 folder {Top Level} vlog_noload 0 last_compile 0 vlog_disableopt 0 vlog_hazard 0 vlog_showsource 0 ood 1 compile_to $$bn vlog_upper 0 vlog_options {} compile_order $$nfiles dont_compile 0 >> tmp.mpf; \
			   nfiles=`expr $$nfiles + 1`; \
			   case $$bn in $(LIBEROLIBSKIP) )\
				uu=0;; \
			   *) \
			    case $$q in $(LIBEROSKIP) ) ;; *) \
	    		      echo VALUE \"\<project\>/$$k/$$l/$$q,hdl\" >> libero_syn_files; \
	    		      echo VALUE \"\<project\>/$$k/$$l/$$q,hdl\" >> libero_sim_files; \
	    		      echo VALUE \"\<project\>/$$k/$$l/$$q,hdl\" >> libero_simlist; \
	  		      echo STATE=\"utd\" >> libero_syn_files; \
	  		      echo LIBRARY=\"$$bn\" >> libero_syn_files; \
	  		      echo ENDFILE >> libero_syn_files;; \
			    esac; \
			   esac; \
		           printf "\t$(VLOG) $$bn $$k/$$l/$$q\n" >> compile.vsim; \
		           printf "\t$(ALOG) $$bn ../../$$k/$$l/$$q\n" >> compile.asim; \
		           printf "\t$(NCVLOG) $$bn $$k/$$l/$$q\n" >> compile.ncsim;; \
			esac ; \
		       fi ;; \
	    	      esac; \
	    	    done ; \
		   fi ; \
	    	  done;; \
	         esac; \
	        done ; \
	        if (test $$bn = "work"); then \
	           for i in $(VHDLSYNFILES) $(VHDLSIMFILES); do \
		     echo " [file]" >> tmp.son; \
		     echo "  name" = $$i >> tmp.son; \
		     echo " []" >> tmp.son; \
	           done; \
                fi ; \
	        echo "[]" >> tmp.son; \
                echo ""; \
            fi ; \
	  esac; \
	done ; \
	for i in $(VHDLSYNFILES); do \
	  echo add_input_file -format VHDL -work work  $$i >> $(TOP)_precision.tcl; \
	  echo set_global_assignment -name VHDL_FILE $$i >> $(TOP).qsf; \
	  echo VALUE \"\<project\>/$$i,hdl\" >> libero_synlist; \
	done; \
	echo setup_design -design $(TOP) >> $(TOP)_precision.tcl; \
	echo setup_design -retiming >> $(TOP)_precision.tcl; \
	echo setup_design -vhdl >> $(TOP)_precision.tcl; \
	echo setup_design -transformations=false >> $(TOP)_precision.tcl; \
	echo setup_design -frequency=\"$(SYNFREQ)\" >> $(TOP)_precision.tcl; \
	echo $(PRECOPT) >> $(TOP)_precision.tcl; \
	echo save_impl >> $(TOP)_precision.tcl; \
	echo "" >> $(TOP).qsf; \
	echo "set_global_assignment -name TOP_LEVEL_ENTITY" \"$(TOP)\" >> $(TOP).qsf; \
	echo "" >> $(TOP)_synplify.qsf; \
	echo "set_global_assignment -name TOP_LEVEL_ENTITY" \"$(TOP)\" >> $(TOP)_synplify.qsf; \
	cat tmp.npl >> $(TOP).npl; \
	echo DEPASSOC $(TOP) $(UCF) >> $(TOP).npl; \
	echo project set \"Bus Delimiter\" \(\) >> $(TOP)_ise.tcl ;\
	echo project set \"FSM Encoding Algorithm\" None >> $(TOP)_ise.tcl ;\
	echo project set \"Pack I/O Registers into IOBs\" yes >> $(TOP)_ise.tcl ;\
	echo project set \"Other XST Command Line Options\" \"$(XSTOPT)\" >> $(TOP)_ise.tcl ;\
	echo project set \"Allow Unmatched LOC Constraints\" true >> $(TOP)_ise.tcl ;\
	echo project set \"Macro Search Path\" \"$(GRLIB)/netlists/xilinx/$(TECHNOLOGY)\" -process \"Translate\" >> $(TOP)_ise.tcl ;\
	echo project set \"Pack I/O Registers/Latches into IOBs\" \{For Inputs and Outputs\} >> $(TOP)_ise.tcl ;\
	echo project set \"Other MAP Command Line Options\" \"$(ISEMAPOPT)\" >> $(TOP)_ise.tcl ;\
	echo project set \"Create ReadBack Data Files\" true >> $(TOP)_ise.tcl ;\
	echo project set \"Create Mask File\" true >> $(TOP)_ise.tcl ;\
	echo project close >> $(TOP)_ise.tcl ;\
	echo exit >> $(TOP)_ise.tcl ;\
	xfiles=`expr $$xfiles + 1`; \
	echo SOURCE synplify/$(TOP).edf >> $(TOP)_synplify.npl; \
	echo DEPASSOC $(TOP) $(UCF) >> $(TOP)_synplify.npl; \
	echo "[Normal]" >> $(TOP).npl; echo "[Normal]" >> $(TOP)_synplify.npl; \
	echo "_SynthFsmEncode=xstvhd, " $(TECHNOLOGY)", VHDL.t_synthesize, 1102507235, None" >> $(TOP).npl; \
	echo "p_xstBusDelimiter=xstvhd, " $(TECHNOLOGY)", VHDL.t_synthesize, 1102507235, ()" >> $(TOP).npl; \
	echo "xilxMapAllowLogicOpt=xstvhd, " $(TECHNOLOGY)", VHDL.t_placeAndRouteDes, 1102861051, True" >>  $(TOP).npl; \
	echo "xilxMapCoverMode=xstvhd, " $(TECHNOLOGY)", VHDL.t_placeAndRouteDes, 1102861051, Speed" >>  $(TOP).npl; \
	echo "xilxMapTimingDrivenPacking=xstvhd, " $(TECHNOLOGY)", VHDL.t_placeAndRouteDes, 1102861051, True" >>  $(TOP).npl; \
	echo "xilxNgdbld_AUL=xstvhd, " $(TECHNOLOGY)", VHDL.t_placeAndRouteDes, 1102861051, True" >>  $(TOP).npl; \
	echo "xilxNgdbldMacro=xstvhd, " $(TECHNOLOGY)", VHDL.t_ngdbuild, 1105377047, "$(GRLIB)/netlists/xilinx/$(TECHNOLOGY) >>  $(TOP).npl; \
	echo "xilxPAReffortLevel=xstvhd, " $(TECHNOLOGY)", VHDL.t_placeAndRouteDes, 1102861051, Medium" >>  $(TOP).npl; \
	echo "xilxMapAllowLogicOpt=edif, " $(TECHNOLOGY)", EDIF.t_placeAndRouteDes, 1102861051, True" >>  $(TOP)_synplify.npl; \
	echo "xilxMapCoverMode=edif, " $(TECHNOLOGY)", EDIF.t_placeAndRouteDes, 1102861051, Speed" >>  $(TOP)_synplify.npl; \
	echo "xilxNgdbld_AUL=edif, " $(TECHNOLOGY)", EDIF.t_placeAndRouteDes, 1102861051, True" >>  $(TOP)_synplify.npl; \
	echo "xilxPAReffortLevel=edif, " $(TECHNOLOGY)", EDIF.t_placeAndRouteDes, 1102861051, Medium" >>  $(TOP)_synplify.npl; \
	echo "xilxNgdbldMacro=edif, " $(TECHNOLOGY)", EDIF.t_placeAndRouteDes, 1105378344, "$(GRLIB)/netlists/xilinx/$(TECHNOLOGY) >>  $(TOP)_synplify.npl; \
	cat $(TOP).npl | sed -e s/'\/'/'\\'/g > tmp.npl; \
	cp tmp.npl $(TOP)_win32.npl; \
	cat $(TOP)_synplify.npl | sed -e s/'\/'/'\\'/g > tmp.npl; \
	cp tmp.npl $(TOP)_synplify_win32.npl; \
	if test $(OS) != "Linux"; then \
	  if test $(OS) != "SunOs"; then \
	    cp $(TOP)_win32.npl $(TOP).npl; \
	    cp $(TOP)_synplify_win32.npl $(TOP)_synplify.npl; \
	  fi; \
	fi; \
	echo "[STRATEGY-LIST]" >> $(TOP).npl; echo "[STRATEGY-LIST]" >> $(TOP)_synplify.npl; \
	echo "Normal=True" >> $(TOP).npl; echo "Normal=True" >> $(TOP)_synplify.npl; \
	echo "DEVSYNTHESISTOOL XST (VHDL/Verilog)" >>  $(TOP).npl; \
	for i in $(VHDLSYNFILES) $(VHDLSIMFILES); do \
	   echo Project_File_$$nfiles = $$i >> tmp.mpf; \
	   echo Project_File_P_$$nfiles = vhdl_novitalcheck 0 file_type VHDL group_id 0 vhdl_nodebug 0 vhdl_1164 1 vhdl_noload 0 vhdl_synth 0 folder {Top Level} last_compile 0 vhdl_disableopt 0 vhdl_vital 0 vhdl_warn1 0 vhdl_warn2 1 vhdl_explicit 0 vhdl_showsource 1 vhdl_warn3 1 vhdl_options {} vhdl_warn4 1 ood 0 vhdl_warn5 0 compile_to $$bn compile_order $$nfiles dont_compile 0 cover_stmt 1 vhdl_use93 93 >> tmp.mpf; \
	   nfiles=`expr $$nfiles + 1`; \
	   printf "\t$(VHDLP) $(VHDLOPT) sonata $$i\n" >> compile.son; \
	done; rm tmp.npl; \
        echo "Project_Sim_Count = 1" >> tmp.mpf; \
	echo "Project_Sim_0 = Simulation 1" >> tmp.mpf; \
	echo "Project_Sim_P_0 = Generics {} timing default -std_output {} +notimingchecks 0 -L {} selected_du {} -hazards 0 -sdf {} +acc {} ok 1 folder {Top Level} -absentisempty 0 +pulse_r {} OtherArgs {} -multisource_delay {} +pulse_e {} -coverage 0 -sdfnoerror 0 +plusarg {} -vital2.2b 0 -t ps additional_dus" work.$(SIMTOP) "-nofileshare 0 -noglitch 0 -wlf {} +no_pulse_msg 0 -assertfile {} -sdfnowarn 0 -Lf {} -std_input {}" >> tmp.mpf; \
	for i in $(GHDLSKIP); do grep -v $$i compile.ghdl > xx; mv xx compile.ghdl; done;\
	for i in $(SONATALIBSKIP); do grep -v $$i compile.son > xx; mv xx compile.son; done;\
	cat $(GRLIB)/bin/modelsim.ini >> modelsim.ini; \
	cp modelsim.ini $(SIMTOP).mpf; \
	echo "[Project]" >> $(SIMTOP).mpf; \
	echo Project_Version = 5 >> $(SIMTOP).mpf; \
	echo Project_DefaultLib = work >> $(SIMTOP).mpf; \
	echo Project_SortMethod = unused >> $(SIMTOP).mpf; \
        echo Project_Files_Count = $$nfiles >> $(SIMTOP).mpf; \
        cat tmp.mpf >> $(SIMTOP).mpf; rm tmp.mpf; \
	cat $(GRLIB)/bin/mt1.mpf >> $(SIMTOP).mpf; \
	echo -P$$ppath > ghdl.path; \
	if test -r "$(QSF)"; then cat $(QSF) >> $(TOP).qsf; fi; \
	echo ghdl: > tmpmake.ghdl;  cat compile.ghdl >> tmpmake.ghdl; \
	echo ncsim: > make.ncsim; cat compile.ncsim >> make.ncsim; \
	echo vsim: > make.vsim; cat compile.vsim >> make.vsim; \
	echo sonata-compile: > make.son; cat compile.son >> make.son; \
	cat compile.asim >> make.asim; \
	for i in $(VHDLSYNFILES) $(VHDLSIMFILES); do \
	  printf "\t$(VCOM) $(VHDLOPT) $$bn $$i\n" >> make.vsim; \
	  printf "\t$(ACOM) $(VHDLOPT) $$bn ../../$$i\n" >> make.asim; \
	  printf "\t$(NCVHDL) $(VHDLOPT) $$bn $$i\n" >> make.ncsim; \
	  printf "\t$(GHDL) $(VHDLOPT) --workdir=gnu/$$bn --work=$$bn -P$$ppath $$i\n" >> tmpmake.ghdl; \
	  echo VALUE \"\<project\>/$$i,hdl\" >> libero_sim_files; \
	  echo VALUE \"\<project\>/$$i,hdl\" >> libero_simlist; \
	  echo VALUE \"\<project\>/$$i,hdl\" >> libero_syn_files; \
	  echo STATE=\"utd\" >> libero_syn_files; \
	  echo LIBRARY=\"work\" >> libero_syn_files; \
	  echo ENDFILE >> libero_syn_files; \
	done; \
	if test -r "$(SDC)"; then \
	  echo VALUE \"\<project\>/$(SDC),sdc\" >> libero_syn_files; \
	  echo STATE=\"utd\" >> libero_syn_files; \
	  echo ENDFILE >> libero_syn_files; \
	fi; \
	if test -r "$(PDC)"; then \
	  echo VALUE \"\<project\>/$(PDC),pdc\" >> libero_syn_files; \
	  echo STATE=\"utd\" >> libero_syn_files; \
	  echo ENDFILE >> libero_syn_files; \
	fi; \
	echo "cd .." > libero.do; \
	echo do libs.do >> libero.do; \
	echo project open $(SIMTOP).mpf >> libero.do; \
	echo project compileoutofdate >> libero.do; \
	echo vsim $(SIMTOP) >> libero.do; \
	echo do wave.do >> libero.do; \
	mkdir simulation; mv libero.do simulation; \
	echo "" > make.asim-addfile; \
	for i in $(VHDLSYNFILES) $(VHDLSIMFILES); do \
	  echo addfile -vhdl ../../$$i >> make.asim-addfile; \
	done; \
	if test -r "$(SIMTOP)".vhd; then \
	  arch=`grep -i architecture $(SIMTOP).vhd | grep -i $(SIMTOP) | awk '{ print $$2}'`; \
	  printf "\tncelab -timescale 10ps/10ps $(SIMTOP):$$arch\n" >> make.ncsim ; \
	fi; \
	echo $(SIMTOP).mpf; \
	for i in $(VHDLSIMFILES); do \
	  echo VALUE \"\<project\>/$$i,hdl\" >> libero_sim_files; \
	done; \
	echo LIST LIBRARIES >> $(TOP)_libero.prj; \
	for i in `cat libs.txt`; do \
	   case $$i in $(LIBEROLIBSKIP) )\
	     uu=0;; \
	   *) \
	     echo $$i >> $(TOP)_libero.prj; \
	   esac; \
	done; \
	cat $(GRLIB)/bin/sonata2.sws >> sonata.sws; \
	cp sonata.sws symphony.ini; \
	cat tmp.son >> sonata.sws; \
	echo "[properties]" >> sonata.sws; \
	echo " work = sonata" >> sonata.sws; \
	echo "[]" >> sonata.sws; \
	echo ENDLIST >> $(TOP)_libero.prj; \
	echo ENDFILELIST >> libero_simlist; \
	echo ENDLIST >> libero_simlist; \
	echo ENDFILELIST >> libero_synlist; \
	echo ENDLIST >> libero_synlist; \
	for i in `cat libs.txt`; do \
	   case $$i in $(LIBEROLIBSKIP) )\
	     uu=0;; \
	   *) \
	     echo LIST LIBRARIES_$$i >> $(TOP)_libero.prj; \
	     echo ALIAS=$$i >> $(TOP)_libero.prj; \
	     echo "COMPILE_OPTION=COMPILE" >> $(TOP)_libero.prj; \
	     echo ENDLIST >> $(TOP)_libero.prj; \
	   esac; \
	done; \
	cat libero_syn_files >> $(TOP)_libero.prj; \
	echo ENDLIST >> $(TOP)_libero.prj; \
	echo LIST SimulationOptions >> $(TOP)_libero.prj; \
	echo ENDLIST >> $(TOP)_libero.prj; \
	echo LIST ExcludePackageForSimulation >> $(TOP)_libero.prj; \
	echo LIST $(TOP) >> $(TOP)_libero.prj; \
	echo ENDLIST >> $(TOP)_libero.prj; \
	echo ENDLIST >> $(TOP)_libero.prj; \
	cat libero_sim_files >> $(TOP)_libero.prj; \
	echo ENDLIST >> $(TOP)_libero.prj; \
	echo ENDLIST >> $(TOP)_libero.prj; \
	echo LIST IncludeModuleForSimulation >> $(TOP)_libero.prj; \
	echo ENDLIST >> $(TOP)_libero.prj; \
	echo LIST UserCustomizedFileList >> $(TOP)_libero.prj; \
	echo LIST \"$(TOP)\" >> $(TOP)_libero.prj; \
	cat libero_synlist >> $(TOP)_libero.prj; \
	cat libero_simlist >> $(TOP)_libero.prj; \
	echo ENDLIST >> $(TOP)_libero.prj; \
	echo ENDLIST >> $(TOP)_libero.prj;
#	for i in $(TOOLSKIP); do \
	  case $$i in \
	  libero ) rm -rf simulation $(TOP)_libero.prj;; \
	  quartus ) rm  $(TOP).q?f;; \
	  ghdl ) rm  compile.ghdl tmpmake.ghdl ;; \
	  sonata ) rm -rf sonata.sws compile.son make.son ;; \
	  esac; \
	done

########## Import from other libraries ###############

import-actel-cc:
	@if test -r $(CORECONSOLE); then \
	  echo "Importing CoreMP7 files from Actel CoreConsole IP Library"; \
	  echo " Importing $(COREMP7BRIDGE_FILES) to lib/techmap/proasic3"; \
	  for i in $(COREMP7BRIDGE_FILES); do cp $(COREMP7BRIDGE_PATH)/$$i $(GRLIB)/lib/techmap/proasic3; done; \
	  echo " Importing $(COREMP7_FILES) to lib/techmap/proasic3";\
	  for i in $(COREMP7_FILES); do cp $(COREMP7_PATH)/$$i $(GRLIB)/lib/techmap/proasic3; done; \
	else \
	  echo "CORECONSOLE environment variable is not correctly set!"; \
	fi

######## Common cleaning   ####################

clean: $(CLEAN) vsim-clean ise-clean ncsim-clean ghdl-clean synplify-clean quartus-clean sonata-clean \
	actel-clean dc-clean rc-clean isp-clean precision-clean vsimsa-clean avhdl-clean riviera-clean
	-rm -rf verilog.txt tkparse.exe main.tk ahbrom outdata ahbrom.bin

scripts-clean:
	-rm -rf compile\.* libs.txt *.qsf *.qpf *\.ghdl ghdl.path \
	compile\.* libs.do make\.* *.xst cds.lib *.npl $(TOP)_ise.tcl \
	config.h .config.old hdl.var $(TOP)_dc.tcl  $(TOP).rc  \
	$(TOP)_synplify.prj $(SIMTOP).mpf tmpmake.ghdl \
	$(TOP)_designer.tcl $(TOP)_designer_act.tcl \
	modelsim.ini \
	alibs.do avhdl.tcl riviera.do

distclean: $(CLEAN) clean scripts-clean

libclean:
	-@rm work.v; \
	for j in `cat libs.txt` work ; do \
	  rm $$j.vhd; \
	done;
	make distclean

none-clean:

######## xconfig targets   ####################

ifneq ($(CURLIB), $(GRLIB))
  include $(GRLIB)/bin/Makefile.config
endif

TKCONFIG= $(GRLIB)/bin/tkconfig

tkparse.o: $(TKCONFIG)/tkparse.c
	$(CC) -g -c $<

tkcond.o: $(TKCONFIG)/tkcond.c
	$(CC) -g -c $<

tkgen.o: $(TKCONFIG)/tkgen.c
	$(CC) -g -c $<


tkparse.exe: tkparse.o tkcond.o tkgen.o
	$(CC) -g tkparse.o tkcond.o tkgen.o -o tkparse.exe

lconfig.tk: config.in $(CONFDEP) $(HELPDEP)
	make main.tk
	cat $(TKCONFIG)/header.tk main.tk $(TKCONFIG)/tail.tk > lconfig.tk
	chmod a+x lconfig.tk

main.tk : config.in tkparse.exe $(CONFDEP) $(HELPDEP)
	./tkparse.exe config.in $(GRLIB) $(EXTRALIBS) > main.tk

$(GRLIB)/bin/Makefile.config:
	make -C $(GRLIB) -f bin/Makefile cfgdep

xconfig: lconfig.tk $(GRLIB)/bin/Makefile.config
	@if test -r "/usr/bin/wish84.exe"; then /usr/bin/wish84.exe -f lconfig.tk; \
	else \
	  if test -r "/mingw/bin/wish84.exe"; then \
	    if !(test -r "/mingw/bin/echo.bat"); then \
	      cp $(GRLIB)/bin/echo.bat /mingw/bin/echo.bat; \
	    fi; \
	    if !(test -r "/mingw/bin/wish"); then \
	      cp $(GRLIB)/bin/wish /mingw/bin/wish; \
	    fi; \
	  fi; \
	  wish -f lconfig.tk; \
	fi; \
	if test $$? = "2" ; then                   \
	   cpp -P -DGRLIB_PATH=$(GRLIB) config.vhd.in > config.vhd; \
	   echo config.vhd created; \
	fi

xdep:
	cpp -P -DGRLIB_PATH=$(GRLIB) config.vhd.in > config.vhd

config:
	cp $(GRLIB)/boards/$(BOARD)/config .config
	cp $(GRLIB)/boards/$(BOARD)/config.h config.h
	make xdep

.PHONY: sonata xst precision synplify scripts netlists bitfiles cut-actel

############ Maintenance - do not remove!   ##################

docs:
	find ./ -name '*.gif' | zip ../grdocs.zip -@
	find ./ -name '*.html' | zip ../grdocs.zip -@
	find ./ -name '*.pdf' | zip ../grdocs.zip -@
	find ./ -name '*.jpg' | zip ../grdocs.zip -@

netlistsft:
	tar czf ../grlib-ft-netlists-$(VER).tar.gz netlists \
	lib/techmap/stratixii/gr*fp*_*_* lib/techmap/unisim/gr*fp*_*_*

netlists:
	tar czf ../grlib-netlists-$(VER).tar.gz netlists \
	lib/techmap/stratixii/gr*fp*_*_* lib/techmap/unisim/gr*fp*_*_*
	rm -rf netlists lib/techmap/*/gr*fp*_*_*

usbhost:
	tar czf ../grlib-usb-$(VER).tar.gz $(USBFILES)
	rm -rf $(USBFILES)

bitfiles:
	@echo creating grlib-bitfiles-$(VER).tar.gz ;\
	tar czf ../grlib-bitfiles-$(VER).tar.gz `find -name '*bitfiles' -print | xargs` ;\
	rm -rf `find -name '*bitfiles' -print | xargs`

cfgdep:
	@printf "CONFDEP = "  > bin/Makefile.config
	@for i in `find lib -name '*.in' -print | grep -v vhd | xargs`; do \
	  echo -n '$$(GRLIB)'/$$i >> bin/Makefile.config ; \
	  printf " \\"  >> bin/Makefile.config ; \
	  printf "\n"  >> bin/Makefile.config ; \
	done;
	@printf "  \n" >> bin/Makefile.config
	@printf "HELPDEP = "  >> bin/Makefile.config
	@for i in `find lib -name '*.in.help' -print | xargs`; do \
	  echo -n '$$(GRLIB)'/$$i >> bin/Makefile.config ; \
	  printf " \\"  >> bin/Makefile.config ; \
	  printf "\n"  >> bin/Makefile.config ; \
	done;
	@printf "  \n" >> bin/Makefile.config

clean-lib:
	@make -f bin/Makefile cfgdep
	@-rm `find -name '*.backup.fm' -print | xargs`
	@-rm `find -name '*.recover.fm' -print | xargs`
	@-rm `find -name '*.backup.book' -print | xargs`
	@-rm `find -name '*.backup.book' -print | xargs`
	@echo "-- pragma translate_off"   > lib/grlib/stdlib/version.vhd ;\
	echo "use std.textio.all;"   >> lib/grlib/stdlib/version.vhd ;\
	echo "-- pragma translate_on"   >> lib/grlib/stdlib/version.vhd ;\
	echo "package version is"   >> lib/grlib/stdlib/version.vhd ;\
	echo "  constant grlib_version : integer := $(GVER);" >> lib/grlib/stdlib/version.vhd ;\
	echo "-- pragma translate_off"   >> lib/grlib/stdlib/version.vhd ;\
	echo -n "  constant grlib_date : string := \""  >> lib/grlib/stdlib/version.vhd ;\
	date +%Y%m%d | tr "\n" "\"" >> lib/grlib/stdlib/version.vhd ;\
	echo ";"     >> lib/grlib/stdlib/version.vhd ;\
	echo "-- pragma translate_on"   >> lib/grlib/stdlib/version.vhd ;\
	echo -n "  constant grlib_build : integer := " >> lib/grlib/stdlib/version.vhd ;\
	svn info | awk '/Revision:/ {print $$2 + 1}'  | tr "\n" ";" >> lib/grlib/stdlib/version.vhd ;\
	echo "" >> lib/grlib/stdlib/version.vhd ;\
	echo "end;"  >> lib/grlib/stdlib/version.vhd ;\

delint:
	@if test -r .svn; then echo .svn found, exiting; exit; fi;
	@rm -rf $(INTFILES)
	@cd doc; mv grlib/grlib.pdf grip/grip.pdf haps/haps.pdf tmtc/tmtc.pdf .; \
	mkdir devices ;\
	mv leon3ft-rtax/leon3-rtax.pdf leon3ft-rtax/leon3-rtax-um.pdf devices; \
	mv ftfpga/ftfpga.pdf grlib-ft-fpga.pdf ; \
	mv gr701/*.pdf devices ; \
	rm -rf grlib grip leon3ft-rtax ftfpga gr701 haps
	@echo creating grlib-haps-$(VER).tar.gz ;\
	tar czf ../grlib-haps-$(VER).tar.gz $(HAPSFILES) ;\
	rm -rf $(HAPSFILES)
	@-rm `find -name '*.fm' -print | xargs`
	@-rm `find -name '*.book' -print | xargs`
	@-rm -rf designs/leon3-ft*/bitfiles
	@make -f bin/Makefile bitfiles
	@cd lib/gaisler; mv leon3sim leon3ft
	@cat lib/techmap/unisim/vhdlsyn.txt | sed -e s/#// > x; mv x lib/techmap/unisim/vhdlsyn.txt
	@cat lib/techmap/axcelerator/vhdlsyn.txt | sed -e s/#// > x; mv x lib/techmap/axcelerator/vhdlsyn.txt

ft: delint
	@if test -r .svn; then echo .svn found, exiting; exit; fi; \
	echo creating grlib-ft-netlists-$(VER).tar.gz ;\
	tar czf ../grlib-ft-netlists-$(VER).tar.gz netlists ;\
	rm -rf netlists lib/techmap/*/gr*fp*_*_*
	rm -rf $(USBFILES) $(COREMP7FILES) $(T1FILES)
	@cd lib/actel/core1553brm; mv dirs_netlist.txt dirs.txt
	@make -f bin/Makefile cfgdep
	@for i in `find -name '*.vhd' -print | xargs`; do \
	  if test -r $$i; then sed -f bin/gr.sed $$i > x; mv x $$i; fi; \
	done
	@xpwd=`pwd`; tname=`basename $$xpwd`; \
	echo creating $$xpwd.tar.gz ;\
	cd .. ; tar czf $$tname.tar.gz $$tname

ftfpga: delint
	@if test -r .svn; then echo .svn found, exiting; exit; fi;
	@cd lib/tech; rm -rf $(ASICLIBS)
	@cd lib/techmap; rm -rf $(ASICLIBS)
	@cd lib/spw; rm -rf core
	@cd boards; rm -rf ge-* altera* jop* ut699rh*
	@rm -rf $(INTFTFPGAFILES) $(USBFILES) $(COREMP7FILES) $(T1FILES)
	@cd lib/actel/core1553brm; mv dirs_netlist.txt dirs.txt
	@make -f bin/Makefile cfgdep
	@for i in `find -name '*.vhd' -print | xargs`; do \
	  if test -r $$i; then sed -f bin/gr.sed $$i > x; mv x $$i; fi; \
	done
	@xpwd=`pwd`; tname=`basename $$xpwd`; \
	echo creating $$xpwd.tar.gz ;\
	cd .. ; tar czf $$tname.tar.gz $$tname

delft: delint
	@if test -r .svn; then echo .svn found, exiting; exit; fi;
	@-rm netlists/*/*/*ft*
	@-rm netlists/*/*/*grspw* ;\
	rm -rf doc/devices doc/grlib-ft-fpga.pdf doc/tmtc.pdf ;\
	echo creating grlib-netlists-$(VER).tar.gz ;\
	tar czf ../grlib-netlists-$(VER).tar.gz netlists ;\
	echo creating grlib-niagara-$(VER).tar.gz ;\
	tar czf ../grlib-niagara-$(VER).tar.gz $(T1FILES) ; \
	rm -rf $(T1FILES) ; \
	echo creating grlib-coremp7-$(VER).tar.gz ;\
	tar czf ../grlib-coremp7-$(VER).tar.gz $(COREMP7FILES) ; \
	rm -rf $(COREMP7FILES) ; \
	rm -rf netlists lib/techmap/*/gr*fp*_*_* ; \
	rm -rf netlists ;\
	rm -rf $(FTFILES)
	@mv software/leon3/Makefile.gpl software/leon3/Makefile
	@make -f bin/Makefile cfgdep

com: delft
	@if test -r .svn; then echo .svn found, exiting; exit; fi; \
	for i in `find -name '*.vhd' -print | xargs`; do \
	  if test -r $$i; then sed -f bin/gr.sed $$i > x; mv x $$i; fi; \
	done ;\
	rm -rf $(CONTRIBLIBS) designs/*ft* designs/t1*;\
	rm -rf lib/spw/netlists ; \
	echo creating grlib-usb-$(VER).tar.gz ;\
	tar czf ../grlib-usb-$(VER).tar.gz $(USBFILES) ; \
	rm -rf $(USBFILES) ; \
	make -f bin/Makefile cfgdep ;\
	xpwd=`pwd`; tname=`basename $$xpwd`; \
	echo creating $$xpwd.tar.gz ;\
	cd .. ; tar czf $$tname.tar.gz $$tname

fpga-com: delft
	@if test -r .svn; then echo .svn found, exiting; exit; fi
	@cd lib/tech; rm -rf $(ASICLIBS)
	@cd lib/techmap; rm -rf $(ASICLIBS)
	@for i in `find -name '*.vhd' -print | xargs`; do \
	  if test -r $$i; then sed -f bin/gr.sed $$i > x; mv x $$i; fi; \
	done ;\
	rm -rf lib/openchip designs/*ft* ;\
	rm -rf lib/spw/netlists ; \
	rm -rf $(USBFILES) ; \
	make -f bin/Makefile cfgdep ;\
	xpwd=`pwd`; tname=`basename $$xpwd`; \
	echo creating $$xpwd.tar.gz ;\
	cd .. ; tar czf $$tname.tar.gz $$tname

gpl: delft
	@if test -r .svn; then echo .svn found, exiting; exit; fi; \
	rm -rf $(COMFILES) ;\
	for i in `find -name '*.vhd' -print | xargs`; do \
	  if test -r $$i; then sed -f bin/gpl.sed $$i > x; mv x $$i; fi; \
	done ;\
	make -f bin/Makefile cfgdep ;\
	xpwd=`pwd`; tname=`basename $$xpwd`; \
	echo creating $$xpwd.tar.gz ;\
	cd .. ; tar czf $$tname.tar.gz $$tname

fpga: delft
	@if test -r .svn; then echo .svn found, exiting; exit; fi
	@cd lib/tech; rm -rf $(ASICLIBS)
	@cd lib/techmap; rm -rf $(ASICLIBS)
	@cd boards; rm -rf ge-* jop*
	@rm -rf $(INTFPGAFILES) ;\
	rm -rf $(COMFILES) ;\
	for i in `find -name '*.vhd' -print | xargs`; do \
	  if test -r $$i; then sed -f bin/gr.sed $$i > x; mv x $$i; fi; \
	done ;\
	make -f bin/Makefile cfgdep ;\
	xpwd=`pwd`; tname=`basename $$xpwd`; \
	echo creating $$xpwd.tar.gz ;\
	cd .. ; tar czf $$tname.tar.gz $$tname

distft:
	@-nsvn=`svn info | awk '/Revision:/ {print $$2 + 1}'` ;\
	rm -rf ~/vhdl/grlib-ft-$(VER)-b$$nsvn ;\
	echo exporting repository to ~/vhdl/grlib-ft-$(VER)-b$$nsvn ;\
	svn export . ~/vhdl/grlib-ft-$(VER)-b$$nsvn ;\
	make -C ~/vhdl/grlib-ft-$(VER)-b$$nsvn ft

distftfpga:
	@-nsvn=`svn info | awk '/Revision:/ {print $$2 + 1}'` ;\
	rm -rf ~/vhdl/grlib-ft-fpga-$(VER)-b$$nsvn ;\
	echo exporting repository to ~/vhdl/grlib-ft-fpga-$(VER)-b$$nsvn ;\
	svn export . ~/vhdl/grlib-ft-fpga-$(VER)-b$$nsvn ;\
	make -C ~/vhdl/grlib-ft-fpga-$(VER)-b$$nsvn ftfpga

distfpga:
	@-nsvn=`svn info | awk '/Revision:/ {print $$2 + 1}'` ;\
	rm -rf ~/vhdl/grlib-fpga-$(VER)-b$$nsvn ;\
	echo exporting repository to ~/vhdl/grlib-fpga-$(VER)-b$$nsvn ;\
	svn export . ~/vhdl/grlib-fpga-$(VER)-b$$nsvn ;\
	make -C ~/vhdl/grlib-fpga-$(VER)-b$$nsvn fpga

distfpga-com:
	@-nsvn=`svn info | awk '/Revision:/ {print $$2 + 1}'` ;\
	rm -rf ~/vhdl/grlib-fpga-com-$(VER)-b$$nsvn ;\
	echo exporting repository to ~/vhdl/grlib-fpga-com-$(VER)-b$$nsvn ;\
	svn export . ~/vhdl/grlib-fpga-com-$(VER)-b$$nsvn ;\
	make -C ~/vhdl/grlib-fpga-com-$(VER)-b$$nsvn fpga-com

distcom:
	@-nsvn=`svn info | awk '/Revision:/ {print $$2 + 1}'` ;\
	rm -rf ~/vhdl/grlib-com-$(VER)-b$$nsvn ;\
	echo exporting repository to ~/vhdl/grlib-com-$(VER)-b$$nsvn ;\
	svn export . ~/vhdl/grlib-com-$(VER)-b$$nsvn ;\
	make -C ~/vhdl/grlib-com-$(VER)-b$$nsvn com

distgpl:
	@-nsvn=`svn info | awk '/Revision:/ {print $$2 + 1}'` ;\
	rm -rf ~/vhdl/grlib-gpl-$(VER)-b$$nsvn ;\
	echo exporting repository to ~/vhdl/grlib-gpl-$(VER)-b$$nsvn ;\
	svn export . ~/vhdl/grlib-gpl-$(VER)-b$$nsvn ;\
	make -C ~/vhdl/grlib-gpl-$(VER)-b$$nsvn gpl

dist:
	make distft distcom distgpl distfpga

axsmall:
	cp $(GRLIB)/lib/tech/axcelerator/components/axcelerator_small.vhd \
	   $(GRLIB)/lib/tech/axcelerator/components/axcelerator.vhd
	cp $(GRLIB)/lib/tech/axcelerator/components/axcelerator_components_small.vhd \
	   $(GRLIB)/lib/tech/axcelerator/components/axcelerator_components.vhd

axfull:
	cp $(GRLIB)/lib/tech/axcelerator/components/axcelerator_full.vhd \
	   $(GRLIB)/lib/tech/axcelerator/components/axcelerator.vhd
	cp $(GRLIB)/lib/tech/axcelerator/components/axcelerator_components_full.vhd \
	   $(GRLIB)/lib/tech/axcelerator/components/axcelerator_components.vhd

cut-lattice:
	mv boards/ge-hpe-mini-lattice .; rm -rf boards/*; mv ge-hpe-mini-lattice boards
	mv designs/leon3-ge-hpe-mini-lattice .; rm -rf designs/*; mv leon3-ge-hpe-mini-lattice designs
	-mkdir x
	mv lib/tech/lattice lib/tech/synplify x; rm -rf lib/tech/*; mv x/* lib/tech
	cd lib/techmap; rm -rf buffers/clkbuf_actel.vhd buffers/clkbuf_xilinx.vhd \
	clocks/clkgen_actel.vhd clocks/clkgen_altera.vhd memory/mem_altera_gen.vhd \
	clocks/clkgen_xilinx.vhd tap/tap_xilinx_gen.vhd ddr/ddr_xilinx.vhd \
	memory/mem_ihp25_gen.vhd memory/mem_xilinx_gen.vhd \
	memory/mem_umc_gen.vhd memory/mem_virage_gen.vhd memory/mem_apa_gen.vhd \
	memory/mem_apa3_gen.vhd memory/mem_axcelerator_gen.vhd \
	pads/pad_atc18_gen.vhd pads/pad_ihp25_gen.vhd pads/pad_rhumc_gen.vhd \
	pads/pad_actel_gen.vhd pads/pad_xilinx_gen.vhd ddr/ddr_xilinx.vhd \
	tap/tap_xilinx_gen.vhd
	cd lib; rm -rf contrib openchip gaisler/usb

cut-altera:
	mkdir x; mv boards/ge-hpe-com* boards/altera* boards/ge-hpe-mini \
	boards/jopdesign-ep1c12 x; rm -rf boards/*; mv x/* boards
	mv designs/leon3-altera-ep1c20 designs/leon3-ge-compact* \
	designs/leon3-jopdesign-ep1c12 designs/leon3-ge-hpe-mini x; \
	rm -rf designs/*; mv x/* designs
	mv lib/tech/altera lib/tech/synplify x; rm -rf lib/tech/*; mv x/* lib/tech
	cd lib/techmap; rm -rf buffers/clkbuf_actel.vhd buffers/clkbuf_xilinx.vhd \
	clocks/clkgen_xilinx.vhd clocks/clkgen_actel.vhd memory/mem_xilinx.vhd \
	memory/mem_ihp25_gen.vhd memory/mem_lattice_gen.vhd ddr/ddr_lattice.vhd \
	memory/mem_umc_gen.vhd memory/mem_virage_gen.vhd memory/mem_apa_gen.vhd \
	memory/mem_apa3_gen.vhd memory/mem_axcelerator_gen.vhd memory/mem_xilinx_gen.vhd \
	pads/pad_atc18_gen.vhd pads/pad_ihp25_gen.vhd pads/pad_rhumc_gen.vhd \
	pads/pad_xilinx_gen.vhd pads/pad_actel_gen.vhd \
	ddr/ddr_xilinx.vhd ddr/ddr_lattice.vhd tap/tap_xilinx_gen.vhd
	rm bin/route_lattice
	cd lib; rm -rf contrib gleichmann openchip gaisler/ddr gaisler/usb


cut-xilinx:
	mkdir x; mv boards/gr-* x; rm -rf boards/*; mv x/* boards; rm -rf boards/gr-cpci-ax
	mv designs/leon3-gr* x; rm -rf designs/*; mv x/* designs; rm -rf designs/leon3-gr-cpci-ax
	mv lib/tech/xilinx lib/tech/synplify x; rm -rf lib/tech/*; mv x/* lib/tech
	cd lib/techmap; rm -rf buffers/clkbuf_actel.vhd \
	clocks/clkgen_actel.vhd clocks/clkgen_altera.vhd memory/mem_altera_gen.vhd \
	memory/mem_ihp25_gen.vhd memory/mem_lattice_gen.vhd ddr/ddr_lattice.vhd \
	memory/mem_umc_gen.vhd memory/mem_virage_gen.vhd memory/mem_apa_gen.vhd \
	memory/mem_apa3_gen.vhd memory/mem_axcelerator_gen.vhd \
	pads/pad_atc18_gen.vhd pads/pad_ihp25_gen.vhd pads/pad_rhumc_gen.vhd \
	pads/pad_actel_gen.vhd  ddr/ddr_lattice.vhd
	cd lib; rm -rf contrib gleichmann openchip


xonly:
	rm compile.dc compile.rc ghdl.path leon3mp_synplify.qpf \
	leon3mp_synplify.qsf verilog.txt tmpmake.ghdl tmp.txt \
	leon3mp_designer.tcl leon3mp_designer_act.tcl leon3mp.rc leon3mp.qsf \
	leon3mp.qpf leon3mp.ise_ISE_Backup leon3mp_dc.tcl

cut-actel:
	-mkdir x
	mv boards/gr-cpci-ax x; rm -rf boards/*; mv x boards/gr-cpci-ax
	mv designs/leon3-gr-cpci-ax x; rm -rf designs/*; mv x designs/leon3-gr-cpci-ax
	rm -rf lib/tech lib/gaisler/ddr
	cd lib/techmap; rm -rf buffers/clkbuf_xilinx.vhd \
	clocks/clkgen_xilinx.vhd clocks/clkgen_altera.vhd memory/mem_altera_gen.vhd \
	memory/mem_ihp25_gen.vhd memory/mem_lattice_gen.vhd \
	memory/mem_umc_gen.vhd memory/mem_virage_gen.vhd memory/mem_xilinx_gen.vhd \
	pads/pad_atc18_gen.vhd pads/pad_ihp25_gen.vhd pads/pad_rhumc_gen.vhd \
	pads/pad_xilinx_gen.vhd ddr/ddr_xilinx.vhd ddr/ddr_lattice.vhd \
	tap/tap_xilinx_gen.vhd
	cd lib; rm -rf contrib gleichmann openchip gaisler/ddr gaisler/usb
