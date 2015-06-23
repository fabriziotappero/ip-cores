SIM_DIR=$(shell pwd)

XPS_PROJ_DIR=$(SIM_DIR)/..
SIM_BIN_DIR=$(SIM_DIR)/sim_bin
COMMON_DIR=$(SIM_DIR)/../../common
LOG_DIR=$(SIM_DIR)/log
PLB_BFM_SETUP_DIR=$(SIM_DIR)/../../plb_bfm_setup


include $(COMMON_DIR)/Makefile



all: sim


TEST_CASES += test_cases/simple_read_write 

WORK_TARGET=$(SIM_BIN_DIR)/work/system/_primary.dat



### 
#
#	note: WORK_TARGET is defined some lines above, the rest in ../../common/Makefile
#
COMPILE_COMPONENTS=$(TESTRAM_TARGET) $(PLB2WB_BRIDGE_TARGET) $(WB_TARGET) $(PLB_BFM_TARGET) $(WORK_TARGET)



#
#	Generate Simulation HDL Files
#   (This is the same than  XPS-Gui->Simulation->Generate Simulation HDL Files)
#
$(SIM_DIR)/behavioral: $(XPS_PROJ_DIR)/system.mhs
	@mkdir -p $(LOG_DIR)
	simgen $(XPS_PROJ_DIR)/system.mhs 	-lang vhdl 					\
													-p virtex5  				\
													-m beh 						\
													-od $(XPS_PROJ_DIR)/ 	\
													-s mti						\
													-lp $(LIB_DIR)				\
													-log $(LOG_DIR)/simgen		
	@mv simgen.opt log	# there is no simgen-flag for this!





# PLB_BFM_TARGET=$(SIM_BIN_DIR)/plbv46_bfm/system/_primary.dat
# #BFM_SOURCE=$() TODO
# $(PLB_BFM_TARGET):
# cd $(SIM_BIN_DIR);																								\
# vlib plbv46_bfm;																									\
# vmap plbv46_bfm plbv46_bfm;																					\
# vlib plbv46_master_bfm_v1_00_a;																				\
# vmap plbv46_master_bfm_v1_00_a plbv46_master_bfm_v1_00_a; 											\
# vlib plbv46_monitor_bfm_v1_00_a;																				\
# vmap plbv46_monitor_bfm_v1_00_a plbv46_monitor_bfm_v1_00_a;											\
# vlib plbv46_slave_bfm_v1_00_a;																				\
# vmap plbv46_slave_bfm_v1_00_a plbv46_slave_bfm_v1_00_a;												\
# vcom $(VHDL_CFLAGS) -work plbv46_bfm																		\
# 	"$(PLB_BFM_SETUP_DIR)/plb_dcl_128.vhd";																\
# vcom $(VHDL_CFLAGS) -work plbv46_master_bfm_v1_00_a													\
# 	"$(PLB_BFM_LIB_DIR)/pcores/plbv46_master_bfm_v1_00_a/hdl/vhdl/plbv46_master_bfm.vhd" ; \
# vcom $(VHDL_CFLAGS) -work plbv46_monitor_bfm_v1_00_a													\
# 	"$(PLB_BFM_LIB_DIR)/pcores/plbv46_monitor_bfm_v1_00_a/hdl/vhdl/plbv46_monitor_bfm.vhd";\
# vcom $(VHDL_CFLAGS) -work plbv46_slave_bfm_v1_00_a														\
# 	"$(PLB_BFM_LIB_DIR)/pcores/plbv46_slave_bfm_v1_00_a/hdl/vhdl/plbv46_slave_bfm.vhd";		

	



$(WORK_TARGET): $(SIM_DIR)/behavioral  $(SIM_BIN_DIR)/../testbench/system_tb.vhd 
	cd $(SIM_BIN_DIR); 	\
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






compile: $(SIM_BIN_DIR)/modelsim.ini $(COMPILE_COMPONENTS)



	


clean:
	rm -rf						\
	$(SIM_DIR)/behavioral 	\
	$(SIM_BIN_DIR)				\
	$(LOG_DIR)

