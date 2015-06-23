PROJECT=avr_core

# the vhdl source files (except testbench)
#
FILES		+= src/*.vhd

# the testbench sources and binary.
#
SIMFILES	= test/test_tb.vhd test/RAMB4_S4_S4.vhd
SIMTOP		= testbench

# When to stop the simulation
#
# GHDL_SIM_OPT	= --assert-level=error
GHDL_SIM_OPT	= --stop-time=40us

SIMDIR		= simu

FLAGS		= --ieee=synopsys --warn-no-vital-generic -fexplicit --std=93c

all:
	make compile
	make run 2>& 1 | grep -v std_logic_arith
	make view

compile:
	@mkdir -p simu
	@echo -----------------------------------------------------------------
	ghdl -i $(FLAGS) --workdir=simu --work=work $(SIMFILES) $(FILES)
	@echo
	@echo -----------------------------------------------------------------
	ghdl -m $(FLAGS) --workdir=simu --work=work $(SIMTOP)
	@echo
	@mv $(SIMTOP) simu/$(SIMTOP)

run:
	@$(SIMDIR)/$(SIMTOP) $(GHDL_SIM_OPT) --vcdgz=$(SIMDIR)/$(SIMTOP).vcdgz

view:
	gunzip --stdout $(SIMDIR)/$(SIMTOP).vcdgz | gtkwave --vcd gtkwave.save

clean:
	ghdl --clean --workdir=simu

