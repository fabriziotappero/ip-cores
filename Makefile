# vhdl files
FILES = src/*
VHDLEX = .vhd
 
# testbench
TESTBENCHPATH = testbench/${TESTBENCH}$(VHDLEX)
 
#GHDL CONFIG
GHDL_CMD = ghdl
GHDL_FLAGS  = --ieee=synopsys --warn-no-vital-generic
 
SIMDIR = simulation
# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=1000ns
 
WAVEFORM_VIEWER = gtkwave
 
all: compile run view
 
new :
	echo "Setting up project ${PROJECT}"
	mkdir src testbench simulation	
 
compile :
ifeq ($(strip $(TESTBENCH)),)
		@echo "TESTBENCH not set. Use TESTBENCH=value to set it."
		@exit 2
endif                                                                                             
 
	mkdir -p simulation
	$(GHDL_CMD) -i $(GHDL_FLAGS) --workdir=simulation --work=work $(TESTBENCHPATH) $(FILES)
	$(GHDL_CMD) -m  $(GHDL_FLAGS) --workdir=simulation --work=work $(TESTBENCH)
	@mv $(TESTBENCH) simulation/$(TESTBENCH)                                                                                
 
run :
	@$(SIMDIR)/$(TESTBENCH) $(GHDL_SIM_OPT) --wave=$(SIMDIR)/$(TESTBENCH).ghw                                     
 
view :
	$(WAVEFORM_VIEWER) --dump=$(SIMDIR)/$(TESTBENCH).ghw                                                 
 
clean :
	$(GHDL_CMD) --clean --workdir=simulation
