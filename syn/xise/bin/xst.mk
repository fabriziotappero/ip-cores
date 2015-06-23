#XDIR = /cygdrive/c/Xilinx92i
#XDIR = /cygdrive/c/Xilinx/12.3/ISE_DS/ISE
#XDIR = "C:/Xilinx/12.3/ISE_DS/ISE"

############################################################################
# Some nice targets
############################################################################

#install: $(PROJECT).bit
#	ljp $< /dev/parport0

floorplan: $(PROJECT).ngd $(PROJECT).par.ncd
	$(FLOORPLAN) $^

report:
	cat *.srp

clean::
	rm -f *.work *.xst
	rm -f *.ngc *.ngd *.bld *.srp *.lso *.prj
	rm -f *.map.mrp *.map.ncd *.map.ngm *.mcs *.par.ncd *.par.pad
	rm -f *.pcf *.prm *.bgn *.drc
	rm -f *.par_pad.csv *.par_pad.txt *.par.par *.par.xpi
	rm -f *.bit
	rm -f *.vcd *.vvp
	rm -f verilog.dump verilog.log
	rm -rf _ngo/
	rm -rf xst/

############################################################################
# Xilinx tools and wine
############################################################################

XST_DEFAULT_OPT_MODE = Speed
XST_DEFAULT_OPT_LEVEL = 1
#DEFAULT_ARCH = spartan3
#DEFAULT_ARCH = virtex4
DEFAULT_ARCH = virtex6
#DEFAULT_PART = xc3s200-ft256-4
#DEFAULT_PART = xc4vlx25-ff668-10
DEFAULT_PART = xc6vlx75t-ff484-1

XBIN = $(XDIR)/bin/nt
#XENV = XILINX=$(XDIR) LD_LIBRARY_PATH=$(XBIN)

#XST 	  = $(XENV) $(XBIN)/xst
#NGDBUILD  = $(XENV) $(XBIN)/ngdbuild
#MAP       = $(XENV) $(XBIN)/map
#PAR       = $(XENV) $(XBIN)/par
#BITGEN    = $(XENV) $(XBIN)/bitgen
#PROMGEN   = $(XENV) $(XBIN)/promgen
#FLOORPLAN = $(XENV) $(XBIN)/floorplanner

XST=$(XBIN)/xst
NGDBUILD=$(XBIN)/ngdbuild
MAP=$(XBIN)/map
PAR=$(XBIN)/par
BITGEN=$(XBIN)/bitgen
PROMGEN=$(XBIN)/promgen
FLOORPLAN=$(XBIN)/floorplanner

XSTWORK   = $(PROJECT).work
XSTSCRIPT = $(PROJECT).xst

.PRECIOUS: %.ngc %.ngc %.ngd %.map.ncd %.bit %.par.ncd

ifndef XST_OPT_MODE
XST_OPT_MODE = $(XST_DEFAULT_OPT_MODE)
endif
ifndef XST_OPT_LEVEL
XST_OPT_LEVEL = $(XST_DEFAULT_OPT_LEVEL)
endif
ifndef ARCH
ARCH = $(DEFAULT_ARCH)
endif
ifndef PART
PART = $(DEFAULT_PART)
endif

compile: $(PROJECT).xst
	$(XST)

$(XSTWORK): $(SOURCES)
	> $@
	for a in $(SOURCES); do echo "vhdl work $$a" >> $@; done

$(XSTSCRIPT): $(XSTWORK)
	> $@
	echo -n "run -ifn $(XSTWORK) -ifmt mixed -top $(TOP) -ofn $(PROJECT).ngc" >> $@
#	echo " -ofmt NGC -p $(PART) -iobuf no -generics {$(GNAME)=$(GVALUE)} -opt_mode $(XST_OPT_MODE) -opt_level $(XST_OPT_LEVEL)" >> $@
	echo " -ofmt NGC -p $(PART) -iobuf no -opt_mode $(XST_OPT_MODE) -opt_level $(XST_OPT_LEVEL)" >> $@
#	echo " -move_first_stage yes -move_last_stage yes -optimize_primitives yes -register_balancing yes" >> $@

%.ngc: $(XSTSCRIPT)
	$(XST) -ifn $<

%.ngd: %.ngc $(PROJECT).ucf
	$(NGDBUILD) -intstyle ise -dd _ngo -uc $(PROJECT).ucf -p $(PART) $*.ngc $*.ngd

%.map.ncd: %.ngd
	$(MAP) -o $@ $< $*.pcf

%.par.ncd: %.map.ncd
	$(PAR) -w -ol high $< $@ $*.pcf

%.bit: %.par.ncd
	$(BITGEN) -w -g UnusedPin:PullNone $< $@ $*.pcf

%.prm: %.bit
	$(PROMGEN) -o $@ -w -u 0  $<

############################################################################
# End
############################################################################
