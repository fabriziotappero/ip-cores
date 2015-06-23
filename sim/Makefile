#VCOM    = /usr/local/bin/vcom 
VCOMOPS = -explicit -check_synthesis -2002 -quiet
VLOGOPS = -vopt -nocovercells
#MAKEFLAGS = --silent
HDL_DIR = ../rtl/vhdl/
VER_DIR = ../rtl/verilog/

##
# hdl files
##
CORE_SRC =$(HDL_DIR)core/std_functions.vhd \
		 $(HDL_DIR)core/mod_sim_exp_pkg.vhd \
		 $(HDL_DIR)ram/dpram_generic.vhd \
		 $(HDL_DIR)ram/tdpram_generic.vhd \
		 $(HDL_DIR)ram/dpram_asym.vhd \
		 $(HDL_DIR)ram/dpramblock_asym.vhd \
		 $(HDL_DIR)core/modulus_ram_asym.vhd \
		 $(HDL_DIR)ram/tdpram_asym.vhd \
		 $(HDL_DIR)ram/tdpramblock_asym.vhd \
		 $(HDL_DIR)core/operand_ram_asym.vhd \
		 $(HDL_DIR)core/modulus_ram_gen.vhd \
		 $(HDL_DIR)core/operand_ram_gen.vhd \
		 $(HDL_DIR)core/adder_block.vhd \
	 	 $(HDL_DIR)core/autorun_cntrl.vhd \
		 $(HDL_DIR)core/cell_1b_adder.vhd \
		 $(HDL_DIR)core/cell_1b_mux.vhd \
		 $(HDL_DIR)core/cell_1b.vhd \
		 $(HDL_DIR)core/counter_sync.vhd \
		 $(HDL_DIR)core/d_flip_flop.vhd \
		 $(HDL_DIR)core/fifo_primitive.vhd \
		 $(HDL_DIR)core/modulus_ram.vhd \
		 $(HDL_DIR)core/mont_ctrl.vhd \
		 $(HDL_DIR)core/mod_sim_exp_core.vhd \
		 $(HDL_DIR)core/operand_dp.vhd \
		 $(HDL_DIR)core/operand_mem.vhd \
		 $(HDL_DIR)core/operand_ram.vhd \
		 $(HDL_DIR)core/operands_sp.vhd \
		 $(HDL_DIR)core/register_1b.vhd \
		 $(HDL_DIR)core/register_n.vhd \
		 $(HDL_DIR)core/standard_cell_block.vhd \
		 $(HDL_DIR)core/stepping_logic.vhd \
		 $(HDL_DIR)core/x_shift_reg.vhd \
		 $(HDL_DIR)core/sys_stage.vhd \
		 $(HDL_DIR)core/sys_last_cell_logic.vhd \
		 $(HDL_DIR)core/sys_first_cell_logic.vhd \
		 $(HDL_DIR)core/sys_pipeline.vhd \
		 $(HDL_DIR)core/mont_multiplier.vhd \
		 $(HDL_DIR)core/pulse_cdc.vhd \
		 $(HDL_DIR)core/clk_sync.vhd \

VER_SRC =$(VER_DIR)generic_fifo_dc.v \
		 $(VER_DIR)generic_fifo_dc_gray.v

##
# Testbench HDL files
##
TB_SRC_DIR = ../bench/vhdl/
TB_SRC =  	$(TB_SRC_DIR)mod_sim_exp_core_tb.vhd \
			$(TB_SRC_DIR)msec_axi_tb.vhd \
			$(TB_SRC_DIR)axi_tb.vhd

##
# Interface HDL files
##
IF_SRC_DIR = ../rtl/vhdl/interface/
IF_SRC =  	$(IF_SRC_DIR)axi/msec_ipcore_axilite.vhd 

#######################################
all: mod_sim_exp

clean:
	rm -rf *_lib work mod_sim_exp *.wlf

mod_sim_exp_lib: 
	vlib mod_sim_exp

work_lib:
	vlib work

libs: mod_sim_exp_lib work_lib

mod_sim_exp_com: mod_sim_exp_lib
	#echo --
	#echo building Modular Exponentiation Core
	#echo --
	vlog $(VLOGOPS) -work mod_sim_exp $(VER_SRC)
	vcom $(VCOMOPS) -work mod_sim_exp $(CORE_SRC)
	#echo Done!

mod_sim_exp_tb: work_lib
	#echo --
	#echo building Modular Exponentiation Core Testbenches
	#echo --
	vcom $(VCOMOPS) -work work $(TB_SRC)

msec_if: work_lib
	#echo --
	#echo building Modular Exponentiation Core Interface
	#echo --
	vcom $(VCOMOPS) -work work $(IF_SRC)

mod_sim_exp: mod_sim_exp_com msec_if mod_sim_exp_tb 
	vsim -c -do mod_sim_exp.do -lib work mod_sim_exp_core_tb

mod_sim_exp_axi: mod_sim_exp_com msec_if mod_sim_exp_tb 
	vsim -c -do mod_sim_exp.do -lib work msec_axi_tb
