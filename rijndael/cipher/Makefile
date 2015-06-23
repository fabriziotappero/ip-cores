#- ------------------------------------------------------------------------
#- Copyright (C) 2010 Arif Endro Nugroho
#- All rights reserved.
#- 
#- Redistribution and use in source and binary forms, with or without
#- modification, are permitted provided that the following conditions
#- are met:
#- 
#- 1. Redistributions of source code must retain the above copyright
#-    notice, this list of conditions and the following disclaimer.
#- 2. Redistributions in binary form must reproduce the above copyright
#-    notice, this list of conditions and the following disclaimer in the
#-    documentation and/or other materials provided with the distribution.
#- 
#- THIS SOFTWARE IS PROVIDED BY ARIF ENDRO NUGROHO "AS IS" AND ANY EXPRESS
#- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#- DISCLAIMED. IN NO EVENT SHALL ARIF ENDRO NUGROHO BE LIABLE FOR ANY
#- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
#- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
#- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#- ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#- POSSIBILITY OF SUCH DAMAGE.
#- 
#- End Of License.
#- ------------------------------------------------------------------------
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
GENPAT    = genpat -v
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
%.pat:		TARGET = $(subst .pat,, $@)
%.cif:		TARGET = $(subst .cif,, $@)
%.vst:		TARGET = $(subst .vst,, $@)
%.flt:		TARGET = $(subst .flt,, $@)
%.sflt:		TARGET = $(subst .sflt,, $@)
%.flatten:	TARGET = $(subst .flatten,, $@)

all:

%.vbe: %.vhdl
	@$(VASY) $(VASYFLAGS) $<

%.vst: %.vbe
	@$(BOOM) $(BOOMFLAGS) $(TARGET) $(TARGET)_o
	@$(BOOG) $(BOOGFLAGS) $(TARGET)_o
	@$(LOON) $(LOONFLAGS) $(TARGET)_o $(TARGET)
	-$(RM) $(TARGET)_o.*

%.sflt: %.vbe 
#	@$(BOOM) $(BOOMFLAGS) $(TARGET)_model $(TARGET)_model_o
	@$(BOOG) $(BOOGFLAGS) $(TARGET)_model
#	@$(BOOG) $(BOOGFLAGS) $(TARGET)_model_o
#	@$(LOON) $(LOONFLAGS) $(TARGET)_model_o $(TARGET)_model
	-$(RM) $(TARGET)_model_o.*
	@$(X2Y) $(X2YFLAGS) $(TARGET) $(TARGET)_m
	@$(FLATLO) $(FLATLOFLAGS) $(TARGET)_m $(TARGET)
#	@$(FLATLO) $(FLATLOFLAGS) $(TARGET)_m $(TARGET)_o
#	@$(LOON) $(LOONFLAGS) $(TARGET)_o $(TARGET)
	-$(RM) $(TARGET){_o,m}.*
	@$(TOUCH) $@

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

clean:
	@rm -vf *.dat *.gpl *.vhd *.vbe *.boom *.vst *.xsc *.ap *.cif *.drc done.* *.flt
