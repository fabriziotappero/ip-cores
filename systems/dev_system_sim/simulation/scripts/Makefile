
CUR_DIR=$(shell pwd)
SIM_DIR=$(CUR_DIR)/..
XPS_PROJ_DIR=$(CUR_DIR)/../..
LIB_DIR=$(CUR_DIR)/../../../EDK_Libs

PLB2WB_LIB_DIR=$(LIB_DIR)/WishboneIPLib/pcores/plb2wb_bridge_v1_00_a
OCRAM_LIB_DIR=$(LIB_DIR)/WishboneIPLib/pcores/testram_v1_00_a
WB_LIB_DIR=$(LIB_DIR)/WishboneIPLib/pcores/wb_conbus_v1_00_a

# VHDL compile flags
VHDL_CFLAGS=-novopt -93 -error -check_synthesis -defercheck -deferSubpgmCheck -rangecheck 

## Uncomment this, if you are at hochschule pforzheim in a pc-pool. 
#  (Check the paths in common/Makefile  ->> vmap entries)
#ENVIRONMENT=HSP


ifeq ( $(ENVIRONMENT), "HSP" )
VMAP= 																														\
	vmap -c;																													\
	vmap secureip 'c:/Programme/CAEE/ISE_Lib/secureip/';														\
	vmap simprim 'c:/Programme/CAEE/ISE_Lib/simprim/';															\
	vmap simprims_ver 'c:/Programme/CAEE/ISE_Lib/simprims_ver/';											\
	vmap unisim 'c:/Programme/CAEE/ISE_Lib/unisim/';															\
	vmap unisims_ver 'c:/Programme/CAEE/ISE_Lib/unisims_ver/';												\
	vmap xilinxcorelib 'c:/Programme/CAEE/ISE_Lib/XilinxCoreLib/';											\
	vmap xilinxcorelib_ver 'c:/Programme/CAEE/ISE_Lib/XilinxCoreLib_ver/';								\
	vmap proc_common_v3_00_a 'c:/Programme/CAEE/EDK_Lib/edk/proc_common_v3_00_a/';					\
	vmap plb_v46_v1_04_a 'c:/Programme/CAEE/EDK_Lib/edk/plb_v46_v1_04_a/';								\
	vmap bfm_synch_v1_00_a 'c:/Programme/CAEE/EDK_Lib/edk/bfm_synch_v1_00_a/';							\
	vmap plbv46_bfm 'c:/Programme/CAEE/EDK_Lib/edk/plbv46_bfm/';											\
	vmap plbv46_master_bfm_v1_00_a 'c:/Programme/CAEE/EDK_Lib/edk/plbv46_master_bfm_v1_00_a/';	\
	vmap plbv46_monitor_bfm_v1_00_a 'c:/Programme/CAEE/EDK_Lib/edk/plbv46_monitor_bfm_v1_00_a/';	\
	vmap plbv46_slave_bfm_v1_00_a 'c:/Programme/CAEE/EDK_Lib/edk/plbv46_slave_bfm_v1_00_a/';		\
	vmap plbv46_slave_single_v1_01_a 'c:/Programme/CAEE/EDK_Lib/edk/plbv46_slave_single_v1_01_a/';

else
VMAP= 																														\
	vmap -c;																													\
	vmap unisim '/opt/Xilinx/11.1/compxlib/unisim/';															\
	vmap unisims_ver '/opt/Xilinx/11.1/compxlib/unisims_ver/';												\
	vmap proc_common_v3_00_a '/opt/Xilinx/11.1/compxlib/edk/proc_common_v3_00_a/';					\
	vmap plb_v46_v1_04_a '/opt/Xilinx/11.1/compxlib/edk/plb_v46_v1_04_a/';								\
	vmap bfm_synch_v1_00_a '/opt/Xilinx/11.1/compxlib/edk/bfm_synch_v1_00_a/';							\
	vmap plbv46_bfm '/opt/Xilinx/11.1/compxlib/edk/plbv46_bfm/';											\
	vmap plbv46_master_bfm_v1_00_a '/opt/Xilinx/11.1/compxlib/edk/plbv46_master_bfm_v1_00_a/';	\
	vmap plbv46_monitor_bfm_v1_00_a '/opt/Xilinx/11.1/compxlib/edk/plbv46_monitor_bfm_v1_00_a/';	\
	vmap plbv46_slave_bfm_v1_00_a '/opt/Xilinx/11.1/compxlib/edk/plbv46_slave_bfm_v1_00_a/';		\
	vlib work;																												\
	vmap work work;																										\
	vlib plb2wb_bridge_v1_00_a;																						\
	vmap plb2wb_bridge_v1_00_a plb2wb_bridge_v1_00_a;
endif


###########
ONCHIP_RAM_TARGET=$(CUR_DIR)/testram_*/testram/_primary.dat
WB_TARGET=$(CUR_DIR)/wb_conbus_*/wb_conbus_*/_primary.dat
WORK_TARGET=$(CUR_DIR)/work/system/_primary.dat
PLB2WB_BRIDGE_TARGET=$(CUR_DIR)/plb2wb_bridge_*/plb2wb_bridge/_primary.dat
###########



###########
PLB2WB_BRIDGE_SRC=$(PLB2WB_LIB_DIR)/hdl/vhdl/*.vhd 	\
		../testbench/plb2wb_amu_tb.vhd 

ONCHIP_RAM_SRC=$(OCRAM_LIB_DIR)/hdl/vhdl/testram.vhd
WB_SRC=$(WB_LIB_DIR)/hdl/verilog/*.v
###########





WORK_SRC= $(SIM_DIR)/behavioral/mb_plb_wrapper.vhd 					\
			 $(SIM_DIR)/behavioral/plb_bfm_master_32_wrapper.vhd		\
			 $(SIM_DIR)/behavioral/plb_bfm_monitor_wrapper.vhd			\
			 $(SIM_DIR)/behavioral/plb_bfm_slave_wrapper.vhd			\
			 $(SIM_DIR)/behavioral/plb_bfm_synch_wrapper.vhd			\
			 $(SIM_DIR)/behavioral/system.vhd 								\
			 $(SIM_DIR)/testbench/system_tb.vhd

VHDL_BRIDGE_SRC=$(SIM_DIR)/behavioral/plb2wb_bridge_0_wrapper.vhd


#
#	Generate Simulation HDL Files
#   (This is the same than  XPS-Gui->Simulation->Generate Simulation HDL Files)
#
$(WORK_SRC): $(XPS_PROJ_DIR)/system.mhs
	simgen $(XPS_PROJ_DIR)/system.mhs 	-lang vhdl 					\
													-p virtex5  				\
													-m beh 						\
													-od $(XPS_PROJ_DIR)/ 	\
													-s mti						\
													-lp $(LIB_DIR)			

#
#
#	Generate the modelsim.ini file and working directory
#		after this, modelsim.ini contains the library mappings
#
modelsim.ini:
	$(VMAP)



#
# Compile the Bus Functional Model script file
#   transfers.bfl: is written in PLB Bus Functional Language
#     (see $XILINX_EDK/third_party/doc/PlbToolkit.pdf )
#   xilbfc:     Bus functional compiler  (perl script)
#

transfers.do: transfers.bfl
	xilbfc transfers.bfl

#
#	Compile the vhdl-sources with modelsim vhdl compiler
#
$(WORK_TARGET): $(WORK_SRC)
	vlib work;				\
	vmap work work;		\
	vlog -novopt -93 -work work  "../behavioral/wb_conbus_0_wrapper.v";			\
	vcom $(VHDL_CFLAGS) -work work \
                              "../behavioral/onchip_ram_0_wrapper.vhd"        \
                              "../behavioral/onchip_ram_1_wrapper.vhd"        \
                              "../behavioral/onchip_ram_2_wrapper.vhd"        \
                              "../behavioral/onchip_ram_3_wrapper.vhd"        \
                              "../behavioral/mb_plb_wrapper.vhd"              \
                              "../behavioral/plb_bfm_master_32_wrapper.vhd"   \
                              "../behavioral/plb_bfm_master_64_wrapper.vhd"   \
                              "../behavioral/plb_bfm_master_128_wrapper.vhd"   \
                              "../behavioral/plb_bfm_monitor_wrapper.vhd"     \
                              "../behavioral/plb_bfm_slave_wrapper.vhd"       \
                              "../behavioral/plb_bfm_synch_wrapper.vhd"       \
                              "../behavioral/plb2wb_bridge_0_wrapper.vhd"     \
                              "../behavioral/system.vhd"                      \
                              "../testbench/system_tb.vhd"


$(PLB2WB_BRIDGE_TARGET): $(PLB2WB_BRIDGE_SRC) 
	vlib plb2wb_bridge_v1_00_a;	
	vmap plb2wb_bridge_v1_00_a plb2wb_bridge_v1_00_a;
	vcom $(VHDL_CFLAGS) -work plb2wb_bridge_v1_00_a 														\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/plb2wb_pkg.vhd"       			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/plb2wb_short_impulse.vhd"     			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_adr_cc_4.vhd"     			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_adr_ic_4.vhd"     			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_adr_cc_3.vhd"     			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_adr_ic_3.vhd"     			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_adr_cc_2.vhd"     			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_adr_ic_2.vhd"     			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_adr_cc_1.vhd"     			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_adr_ic_1.vhd"     			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_adr.vhd"        			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_rdat_cc_32.vhd"  			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_rdat_ic_32.vhd"  			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_rdat.vhd"        			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_wdat_cc_32.vhd"  			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_wdat_ic_32.vhd"  			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_wdat.vhd"        			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_stat2plb.vhd"    			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_stat2plb_ic_4.vhd"		\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_stat2plb_cc_4.vhd"		\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_stat2plb_ic_3.vhd"		\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_stat2plb_cc_3.vhd"		\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_stat2plb_ic_2.vhd"		\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_stat2plb_cc_2.vhd"		\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_stat2plb_ic_1.vhd"		\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_stat2plb_cc_1.vhd"		\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_stat2wb.vhd"    			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_stat2wb_ic.vhd"			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/fifo_stat2wb_cc.vhd"			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/plb2wb_fifo.vhd"      			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/plb2wb_stu.vhd"	    			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/plb2wb_tcu.vhd"       			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/plb2wb_amu.vhd"       			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/plb2wb_rbuf.vhd"      			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/plb2wb_wbuf.vhd"      			\
	"$(PLB2WB_LIB_DIR)/hdl/vhdl/plb2wb_bridge.vhd"



$(ONCHIP_RAM_TARGET): $(ONCHIP_RAM_SRC) 
	vlib testram_v1_00_a; 
	vmap testram_v1_00_a testram_v1_00_a; 
	vcom $(VHDL_CFLAGS) -work testram_v1_00_a $(OCRAM_LIB_DIR)/hdl/vhdl/testram.vhd


$(WB_TARGET): $(WB_SRC) 
	vlib wb_conbus_v1_00_a; 
	vmap wb_conbus_v1_00_a wb_conbus_v1_00_a; 
	vlog -novopt -93 -work wb_conbus_v1_00_a "$(WB_LIB_DIR)/hdl/verilog/wb_conbus_arb.v"       \
   	                                      "$(WB_LIB_DIR)/hdl/verilog/wb_conbus_top.v"       \
      	                                   "$(WB_LIB_DIR)/hdl/verilog/wb_conbus_wrapper.v"



compile: modelsim.ini $(ONCHIP_RAM_TARGET) $(WORK_TARGET) $(PLB2WB_BRIDGE_TARGET) $(WB_TARGET)

sim: modelsim.ini transfers.do $(ONCHIP_RAM_TARGET) $(WORK_TARGET) $(PLB2WB_BRIDGE_TARGET) $(WB_TARGET)
	vsim -quiet -l simulation.log -do sim.do


sim_fifo: ./plb2wb_bridge_*/plb2wb_bridge/_primary.dat
	vsim -quiet -do sim_fifo.do

sim_amu : ./plb2wb_bridge_*/plb2wb_bridge/_primary.dat 
	vsim -quiet -do sim_amu.do

sim_clk_trans: ./plb2wb_bridge_*/plb2wb_bridge/_primary.dat 
	vsim -quiet -do sim_clk_trans.do

clean:
	rm -rf work \
simgen.log \
simgen.opt \
transcript \
vsim.wlf \
modelsim.ini \
../behavioral \
xilbfc.log \
plb2wb_bridge_v1_00_a \
wb_conbus_v1_00_a \
testram_v1_00_a \
wb_conbus_v1_00_a \
bfm_synch_v1_00_a \
plb_v46_v1_04_a \
plbv46_bfm \
plbv46_master_bfm_v1_00_a \
plbv46_monitor_bfm_v1_00_a \
plbv46_slave_bfm_v1_00_a \
plbv46_slave_single_v1_01_a \
proc_common_v3_00_a \
modelsim_proj.cr.mti \
transfers.do
