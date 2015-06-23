TOP_LEVEL_DIR=../..
DESIGN_DIR=.

MBLITE_HW_DIR=$(TOP_LEVEL_DIR)/hw
MBLITE_STD_DIR=$(MBLITE_HW_DIR)/std
MBLITE_CORE_DIR=$(MBLITE_HW_DIR)/core

WORK_DIR=$(DESIGN_DIR)/work
MODELSIM_WORK_DIR=$(WORK_DIR)/modelsim
XILINX_WORK_DIR=$(WORK_DIR)/xilinx

MBLITE_LIBRARY_NAME=mblite
WORK_LIBRARY_NAME=work

default:
	@echo "Makefile for the MB-lite microprocessor"
	@echo "---------------------------------------"
	@echo "Make options:"
	@echo "   default: Echo these instructions"
	@echo "  modelsim: Build Modelsim project"
	@echo "    xilinx: Build Xilinx project"
	@echo "     clean: Remove all compiled and generated files"

modelsim: modelsim-design

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
	@vcom -work $(WORK_LIBRARY_NAME) $(DESIGN_DIR)/testbench.vhd

# Copy memory and do files to work dir
modelsim-init:
	@cp $(DESIGN_DIR)/*.mem $(MODELSIM_WORK_DIR)
	@cp $(DESIGN_DIR)/*.do $(MODELSIM_WORK_DIR)

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

# Compile MB-LITE core
modelsim-core: modelsim-std modelsim-mblite-config
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/core_Pkg.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/core.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/fetch.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/gprf.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/decode.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/execute.vhd
	@vcom -work $(MBLITE_LIBRARY_NAME) $(MBLITE_CORE_DIR)/mem.vhd

#############################
# Create xilinx ISE project #
#############################

xilinx: xilinx-clean
	@mkdir -p $(XILINX_WORK_DIR)
	@xtclsh $(DESIGN_DIR)/Xilinx.tcl

###########################
# Remove work directories #
###########################

xilinx-clean:
	@rm -rf core.gise
	@rm -rf core.xise

clean:
	@rm -rf $(WORK_DIR)
	@rm -f transcript
	@rm -f modelsim.ini
	@rm -f vsim.wlf