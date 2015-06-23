# $Id: Makefile,v 1.3 2008-08-10 09:21:32 arif_endro Exp $
# 
#
# Author  : "Arif E. Nugroho" <arif_endro@yahoo.com>
#
# Copyright (c) 2005, 2008 Arif E. Nugroho
#
# Need to FLATTENING the design before OCP and NERO
# Use x2y vst vst <source> <result>
# then flatlo -r <source> <result> # source is a result from x2y
# this two sequence will remove most warning/error message when
# performing LOON on the netlist.
#
# BOOM will optimize the logic
# BOOG will optimize/convert the logic into netlist
# LOON will optimize the netlist (this will report area/timing)
#
# VST is a circuit netlist file
# AP  is a circuit placement file (OCP/NERO create this file)
# VBE is alliance VHDL Behavioral Description file

VASYFLAGS = -V -B -I vhdl -a -p -o
BOOMFLAGS = -VP
BOOGFLAGS = 
LOONFLAGS = 
OCPFLAGS  = -v
NEROFLAGS = -V -G -6 -p
DRUCFLAGS = 
S2RFLAGS  = -v
OCP	  = ocp
NERO	  = nero
DRUC      = druc
S2R       = s2r
VASY	  = vasy
BOOM      = boom
BOOG      = boog
LOON	  = loon
RM	  = /bin/rm -vf
X2Y	  = x2y
FLATLO	  = flatlo
X2YFLAGS  = vst vst
FLATLOFLAGS    = -r
TOUCH	  = touch

# Set-up TARGET variable respectively
%.ap:		TARGET = $(subst .ap,, $@)
%.cif:		TARGET = $(subst .cif,, $@)
%.vst:		TARGET = $(subst .vst,, $@)
%.flt:		TARGET = $(subst .flt,, $@)
%.flatten:	TARGET = $(subst .flatten,, $@)

all: done.s2r

%.vbe: %.vhdl
	@$(VASY) $(VASYFLAGS) $<

%.vst: %.vbe
	@$(BOOM) $(BOOMFLAGS) $(TARGET) $(TARGET)_o
	@$(BOOG) $(BOOGFLAGS) $(TARGET)_o
	@$(LOON) $(LOONFLAGS) $(TARGET)_o $(TARGET)
	-$(RM) $(TARGET)_o.*

%.flt: %.vbe 
	@$(BOOM) $(BOOMFLAGS) $(TARGET)_model $(TARGET)_model_o
	@$(BOOG) $(BOOGFLAGS) $(TARGET)_model_o
	@$(LOON) $(LOONFLAGS) $(TARGET)_model_o $(TARGET)_model
	-$(RM) $(TARGET)_model_o.*
	@$(X2Y) $(X2YFLAGS) $(TARGET) $(TARGET)_m
	@$(FLATLO) $(FLATLOFLAGS) $(TARGET)_m $(TARGET)_o
	@$(LOON) $(LOONFLAGS) $(TARGET)_o $(TARGET)
	-$(RM) $(TARGET){_o,m}.*
	@$(TOUCH) $@

%.flatten: %.vst
	@$(X2Y) $(X2YFLAGS) $(TARGET) $(TARGET)_m
	@$(FLATLO) $(FLATLOFLAGS) $(TARGET)_m $(TARGET)_o
	@$(LOON) $(LOONFLAGS) $(TARGET)_o $(TARGET)
	-$(RM) $(TARGET){_o,m}.*

FLATS = adder_09bit.flt adder_10bit.flt adder_11bit.flt adder_12bit.flt adder_13bit.flt adder_14bit.flt adder_15bit.flt adder_16bit.flt adder_18bit.flt adder_16bit_u.flt sub_12bit.flt mult_8bit.flt addacc.flt fir.flt loop_filter.flt nco.flt phase_detector.flt fm.flt

NETS = fulladder.vst rom.vst

done.syn: $(NETS) $(FLATS)
	@$(TOUCH) $@

%.ap: done.syn
	@$(OCP) $(OCPFLAGS) -ioc $(TARGET) -gnuplot $(TARGET) $(TARGET)

done.nero: fm.ap
	@$(NERO) $(NEROFLAGS) fm fm fm
	@$(TOUCH) $@

done.druc: done.nero
	@$(DRUC) fm
	@$(TOUCH) $@

done.s2r: done.nero
	@$(S2R) $(S2RFLAGS) fm
	@$(TOUCH) $@

fm_chip.vst: fm_chip.c
	@genlib $<

clean:
	@rm -vf *.dat *.gpl *.vhd *.vbe *.boom *.pat *.vst *.xsc *.ap *.cif *.drc done.* *.flt
