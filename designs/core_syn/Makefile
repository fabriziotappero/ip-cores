TOP_LEVEL_DIR=../..

DESIGN_NAME=core_syn
DESIGN_DIR=$(TOP_LEVEL_DIR)/designs/$(DESIGN_NAME)

MBLITE_HW_DIR=$(TOP_LEVEL_DIR)/hw
MBLITE_STD_DIR=$(MBLITE_HW_DIR)/std
MBLITE_CORE_DIR=$(MBLITE_HW_DIR)/core

MBLITE_LIBRARY_NAME=mblite

SIM_DIR=$(DESIGN_DIR)/work
MODELSIM_SIM_DIR=$(SIM_DIR)/modelsim
MODELSIM_WORK_DIR=$(MODELSIM_SIM_DIR)/$(DESIGN_NAME)

WORK_LIBRARY_NAME=work

default:
	@echo "Makefile for the MB-lite microprocessor"
	@echo "---------------------------------------"
	@echo "Make options:"
	@echo "   default: Echo these instructions"
	@echo "       all: Compile MODEL to library work"
	@echo "            Compile TESTBENCH to library work"
	@echo "       syn: Compile SYNTHESIZED MODEL to library work"
	@echo "            Compile TESTBENCH to library work"
	@echo "       par: Compile PAR MODEL to library work"
	@echo "            Compile TESTBENCH to library work"
	@echo "     clean: Remove all compiled and generated files"

all: modelsim-design
syn: modelsim-syn
par: modelsim-par

################
# WORK library #
################

# Create library WORK
modelsim-worklib:
	@vlib $(MODELSIM_WORK_DIR)/$(WORK_LIBRARY_NAME)
	@vmap $(WORK_LIBRARY_NAME) $(MODELSIM_WORK_DIR)/$(WORK_LIBRARY_NAME)

# Compile MB-LITE configuration to library MB-LITE
modelsim-mblite-config: modelsim-mblitelib
	@vcom -work $(MBLITE_LIBRARY_NAME) $(DESIGN_DIR)/config_Pkg.vhd

# Compile a design using MB-LITE to library WORK
modelsim-design: modelsim-std modelsim-mblite-config modelsim-core modelsim-worklib
	@vcom -work $(WORK_LIBRARY_NAME) $(DESIGN_DIR)/sram_4en_init.vhd
	@vcom -work $(WORK_LIBRARY_NAME) $(DESIGN_DIR)/sram_init.vhd
	@vcom -work $(WORK_LIBRARY_NAME) $(DESIGN_DIR)/mblite_soc.vhd
	@vcom -work $(WORK_LIBRARY_NAME) $(DESIGN_DIR)/testbench.vhd

modelsim-syn: modelsim-std modelsim-mblite-config modelsim-worklib
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/core_Pkg.vhd
	@vcom -work $(WORK_LIBRARY_NAME) $(DESIGN_DIR)/mblite_soc_synthesis.vhd
	@vcom -work $(WORK_LIBRARY_NAME) $(DESIGN_DIR)/testbench.vhd

modelsim-par: modelsim-std modelsim-mblite-config modelsim-worklib
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/core_Pkg.vhd
	@vcom -work $(WORK_LIBRARY_NAME) $(DESIGN_DIR)/mblite_soc_timesim.vhd
	@vcom -work $(WORK_LIBRARY_NAME) $(DESIGN_DIR)/testbench.vhd

###################
# MB-LITE library #
###################

# Create library MB-LITE
modelsim-mblitelib:
	@mkdir -p $(MODELSIM_WORK_DIR)
	@vlib $(MODELSIM_WORK_DIR)/$(MBLITE_LIBRARY_NAME)
	@vmap $(MBLITE_LIBRARY_NAME) $(MODELSIM_WORK_DIR)/$(MBLITE_LIBRARY_NAME)

# Compile MB-LITE standard components
modelsim-std: modelsim-mblitelib
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_STD_DIR)/std_Pkg.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_STD_DIR)/dsram.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_STD_DIR)/sram_4en.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_STD_DIR)/sram.vhd

# Compile MB-LITE processor
modelsim-core: modelsim-std modelsim-mblite-config
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/core_Pkg.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/core.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/fetch.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/gprf.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/decode.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/execute.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/mem.vhd

###########################
# Remove work directories #
###########################

modelsim-clean:
	@rm -r -f $(MODELSIM_WORK_DIR)

clean:
	@rm -r -f $(SIM_DIR)
	@rm -f transcript
	@rm -f modelsim.ini
	@rm -f vsim.wlf