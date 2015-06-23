WB_SRC=$(WISHBONE_LIB_DIR)/pcores/wb_conbus_v1_00_a/hdl/verilog/*.v 
TESTRAM_SRC=$(WISHBONE_LIB_DIR)/pcores/testram_v1_00_a/hdl/vhdl/testram.vhd
PLB2WB_BRIDGE_SRC=$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/*.vhd


PLB2WB_BRIDGE_TARGET=$(SIM_BIN_DIR)/plb2wb_bridge_*/plb2wb_bridge/_primary.dat
TESTRAM_TARGET=$(SIM_BIN_DIR)/testram_*/testram/_primary.dat
WB_TARGET=$(SIM_BIN_DIR)/wb_conbus_*/wb_conbus_*/_primary.dat




VMAP_WIN= 																														\
	vmap -c;																													\
	vmap unisim 'c:/Programme/CAEE/ISE_Lib/unisim/';															\
	vmap bfm_synch_v1_00_a 'c:/Programme/CAEE/EDK_Lib/bfm_synch_v1_00_a/';							\
	vmap plb_v46_v1_04_a 'c:/Programme/CAEE/EDK_Lib/plb_v46_v1_00_a/';								\
	vmap plbv46_bfm 'c:/Programme/CAEE/EDK_Lib/edk/plbv46_bfm/';											\
	vmap plbv46_master_bfm_v1_00_a 'c:/Programme/CAEE/EDK_Lib/edk/plbv46_master_bfm_v1_00_a/';	\
	vmap plbv46_monitor_bfm_v1_00_a 'c:/Programme/CAEE/EDK_Lib/edk/plbv46_monitor_bfm_v1_00_a/';	\
	vmap plbv46_slave_bfm_v1_00_a 'c:/Programme/CAEE/EDK_Lib/edk/plbv46_slave_bfm_v1_00_a/';		\
	vmap proc_common_v3_00_a 'c:/Programme/CAEE/EDK_Lib/edk/proc_common_v3_00_a/';					\
	vlib work;																												\
	vmap work work;																										\
	vlib plb2wb_bridge_v1_00_a;																						\
	vmap plb2wb_bridge_v1_00_a plb2wb_bridge_v1_00_a;

VMAP= 																														\
	vmap -c;																													\
	vmap unisims_ver '/opt/Xilinx/11.1/compxlib/unisims_ver/';															\
	vmap unisim '/opt/Xilinx/11.1/compxlib/unisim/';															\
	vmap bfm_synch_v1_00_a '/opt/Xilinx/11.1/compxlib/edk/bfm_synch_v1_00_a/';							\
	vmap plb_v46_v1_04_a '/opt/Xilinx/11.1/compxlib/edk/plb_v46_v1_04_a/';								\
	vmap plbv46_bfm '/opt/Xilinx/11.1/compxlib/edk/plbv46_bfm/';											\
	vmap plbv46_master_bfm_v1_00_a '/opt/Xilinx/11.1/compxlib/edk/plbv46_master_bfm_v1_00_a/';	\
	vmap plbv46_monitor_bfm_v1_00_a '/opt/Xilinx/11.1/compxlib/edk/plbv46_monitor_bfm_v1_00_a/';	\
	vmap plbv46_slave_bfm_v1_00_a '/opt/Xilinx/11.1/compxlib/edk/plbv46_slave_bfm_v1_00_a/';		\
	vmap proc_common_v3_00_a '/opt/Xilinx/11.1/compxlib/edk/proc_common_v3_00_a/';					\
	vlib work;																												\
	vmap work work;																										\
	vlib plb2wb_bridge_v1_00_a;																						\
	vmap plb2wb_bridge_v1_00_a plb2wb_bridge_v1_00_a;





###
#
#	Generate the modelsim.ini file and working directory
#		after this, modelsim.ini contains the library mappings
#
$(SIM_BIN_DIR)/modelsim.ini:
	@mkdir -p $(SIM_BIN_DIR)
	@echo " "
	@if [ "$(ENVIRONMENT)" = "cygwin" ]; then 	\
		cd $(SIM_BIN_DIR); $(VMAP_WIN)			\
	else													\
		cd $(SIM_BIN_DIR); $(VMAP)					\
	fi
	@echo " "
	@echo " "






###
#
# Compile testram
#
$(TESTRAM_TARGET):  $(TESTRAM_SRC) 
	cd $(SIM_BIN_DIR); 	\
	vlib testram_v1_00_a; \
	vmap testram_v1_00_a testram_v1_00_a; \
	vcom $(VHDL_CFLAGS) -work testram_v1_00_a $(WISHBONE_LIB_DIR)/pcores/testram_v1_00_a/hdl/vhdl/testram.vhd


###
#
# Compile Wishbone-BUS
#
$(WB_TARGET): $(WB_SRC)
	cd $(SIM_BIN_DIR); 	\
	vlib wb_conbus_v1_00_a; \
	vmap wb_conbus_v1_00_a wb_conbus_v1_00_a; \
	vlog -novopt -93 -work wb_conbus_v1_00_a "$(WISHBONE_LIB_DIR)/pcores/wb_conbus_v1_00_a/hdl/verilog/wb_conbus_arb.v"       \
   	                                      "$(WISHBONE_LIB_DIR)/pcores/wb_conbus_v1_00_a/hdl/verilog/wb_conbus_top.v"       \
      	                                   "$(WISHBONE_LIB_DIR)/pcores/wb_conbus_v1_00_a/hdl/verilog/wb_conbus_wrapper.v"



###
#
# Compile PLB2WB-Bridge
#
$(PLB2WB_BRIDGE_TARGET): $(PLB2WB_BRIDGE_SRC)
	echo "VHDL-Flags: $(VHDL_CFLAGS)"
	cd $(SIM_BIN_DIR); \
	vlib plb2wb_bridge_v1_00_a;	\
	vmap plb2wb_bridge_v1_00_a plb2wb_bridge_v1_00_a;\
	vcom $(VHDL_CFLAGS) -work plb2wb_bridge_v1_00_a 														\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/plb2wb_pkg.vhd"       			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/plb2wb_short_impulse.vhd"     			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_adr_cc_4.vhd"     			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_adr_ic_4.vhd"     			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_adr_cc_3.vhd"     			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_adr_ic_3.vhd"     			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_adr_cc_2.vhd"     			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_adr_ic_2.vhd"     			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_adr_cc_1.vhd"     			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_adr_ic_1.vhd"     			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_adr.vhd"        			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_rdat_cc_32.vhd"  			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_rdat_ic_32.vhd"  			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_rdat.vhd"        			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_wdat_cc_32.vhd"  			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_wdat_ic_32.vhd"  			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_wdat.vhd"        			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_stat2plb.vhd"    			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_stat2plb_ic_4.vhd"		\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_stat2plb_cc_4.vhd"		\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_stat2plb_ic_3.vhd"		\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_stat2plb_cc_3.vhd"		\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_stat2plb_ic_2.vhd"		\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_stat2plb_cc_2.vhd"		\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_stat2plb_ic_1.vhd"		\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_stat2plb_cc_1.vhd"		\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_stat2wb.vhd"    			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_stat2wb_ic.vhd"			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/fifo_stat2wb_cc.vhd"			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/plb2wb_fifo.vhd"      			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/plb2wb_stu.vhd"	    			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/plb2wb_tcu.vhd"       			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/plb2wb_amu.vhd"       			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/plb2wb_rbuf.vhd"      			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/plb2wb_wbuf.vhd"      			\
	"$(WISHBONE_LIB_DIR)/pcores/plb2wb_bridge_v1_00_a/hdl/vhdl/plb2wb_bridge.vhd"




