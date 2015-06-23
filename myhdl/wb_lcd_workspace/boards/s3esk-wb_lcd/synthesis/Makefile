#############################################################################
# Master path definitions

TOPDIR?=$(shell pwd)
TOOLS_DIR=$(TOPDIR)/../../../tools
CORE_DIR=$(TOPDIR)/../../../rtl
BOARD_DIR=$(TOPDIR)/../rtl
#CHIPSCOPE_DIR=$(TOPDIR)/../chipscope

#############################################################################
# Board and core source files for synthesis and simulation

BOARD_SYN=$(wildcard $(BOARD_DIR)/*.v)
BOARD_SIM=$(wildcard $(BOARD_DIR)/*.v)

CORE_SRCS=$(wildcard $(CORE_DIR)/*.v)
#CHIPSCOPE_SRCS=$(wildcard $(CHIPSCOPE_DIR)/*.v)

SYN_SRC=		\
	$(BOARD_SYN)	\
	$(CORE_SRCS)

#SYN_SRC=		\
#	$(BOARD_SYN)	\
#	$(CORE_SRCS)	\
#	$(CHIPSCOPE_SRCS)

SIM_SRC=		\
	$(BOARD_SYN)	\
	$(CORE_SRCS)

VINCDIR=		\
	-I$(CORE_DIR)	\
        -I$(BOARD_DIR)


#############################################################################
# Syntheis constants
SYNCLEAN=system.bgn system.drc system.mrp system.ngd system.pcf
SYNCLEAN+=system.bld system.lso system.ncd system.ngm system.srp
SYNCLEAN+=system.bit system_signalbrowser.* system-routed_pad.tx system.bin
SYNCLEAN+=system.map system_summary.xml timing.twr
SYNCLEAN+=system-routed* system_usage* system.ngc param.opt netlist.lst
SYNCLEAN+=xst system.prj system.prm
SYNCLEAN+=*.lso
# for ISE 10.1
SYNCLEAN+=xlnx_auto_0.ise system_par.xrpt smartpreview.twr system.ngc_xst.xrpt
SYNCLEAN+=system_ngdbuild.xrpt system_map.xrpt xlnx_auto_0_xdb _impactbatch.log

USAGE_DEPTH=5
SMARTGUIDE= 
#############################################################################
# Simulation constants
SIMCLEAN=system_sim.vvp system_sim.vcd verilog.log system_sim.vvp.list

CVER=cver
GTKWAVE=gtkwave
IVERILOG=iverilog
VVP=vvp
	
#############################################################################
# 
all: system.bit system.bin
sim: system_sim.vcd
syn: system.bit
view: system_sim.view

#############################################################################
# Icarus verilog simulation

system_sim.vvp: $(SIM_SRC)
	rm -f $@.list
	@for i in `echo $^`; do \
	    echo $$i >> $@.list; \
	done
	$(IVERILOG) -o $@ $(VINCDIR) -c $@.list -s $(@:.vvp=) -s glbl

%.vcd: %.vvp
	$(VVP) $<

#############################################################################
# ISE Synthesis

system.prj: $(SYN_SRC)
	rm -f system.prj
	@for i in `echo $^`; do \
	    echo "verilog work $$i" >> system.prj; \
	done

system.ngc: system.prj
	xst -ifn system.xst

system.ngd: system.ngc system.ucf
	ngdbuild -uc system.ucf system.ngc
#	ngdbuild -uc system.ucf -sd $(CHIPSCOPE_DIR) system.ngc

system.ncd: system.ngd
	map $(SMARTGUIDE) system.ngd

system-routed.ncd: system.ncd
	par $(SMARTGUIDE) -ol high -w system.ncd system-routed.ncd

system.bit: system-routed.ncd
	bitgen -w system-routed.ncd system.bit

system.bin: system.bit
	promgen -u 0x0 system.bit -p bin -w

system.mcs: system.bit
	promgen -u 0 system

system-routed.xdl: system-routed.ncd
	xdl -ncd2xdl system-routed.ncd system-routed.xdl

system-routed.twr: system-routed.ncd
	trce -v 10 system-routed.ncd system.pcf

timing: system-routed.twr

usage: system-routed.xdl
	$(TOOLS_DIR)/xdlanalyze/xdlanalyze.pl system-routed.xdl $(USAGE_DEPTH)

####################################################################
# final targets

load: system.bit
	impact -batch impact.batch

#analyze: load
#	analyzer.sh

%.view: %.vcd
	$(GTKWAVE) $< $<.save

clean:
	rm -Rf $(SYNCLEAN) $(SIMCLEAN)

.PHONY: clean view

