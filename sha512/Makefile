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
	@rm -vf *.dat *.gpl *.vhd *.vbe *.boom *.vst *.xsc *.ap *.cif *.drc done.* *.flt *.sflt *_syn.pat *_sim.pat
