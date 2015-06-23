#####################################################################################
# Copyright (C) 1991-2007 Altera Corporation
# Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
# support information,  device programming or simulation file,  and any other
# associated  documentation or information  provided by  Altera  or a partner
# under  Altera's   Megafunction   Partnership   Program  may  be  used  only
# to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
# other  use  of such  megafunction  design,  netlist,  support  information,
# device programming or simulation file,  or any other  related documentation
# or information  is prohibited  for  any  other purpose,  including, but not
# limited to  modification,  reverse engineering,  de-compiling, or use  with
# any other  silicon devices,  unless such use is  explicitly  licensed under
# a separate agreement with  Altera  or a megafunction partner.  Title to the
# intellectual property,  including patents,  copyrights,  trademarks,  trade
# secrets,  or maskworks,  embodied in any such megafunction design, netlist,
# support  information,  device programming or simulation file,  or any other
# related documentation or information provided by  Altera  or a megafunction
# partner, remains with Altera, the megafunction partner, or their respective
# licensors. No other licenses, including any licenses needed under any third
# party's intellectual property, are provided herein.
#####################################################################################

#####################################################################################
# Altera Triple-Speed Ethernet Megacore NativeLink TCL script
#
# This script should be sourced from the Quartus II TCL console prior to 
# simulating using NativeLink 
#
# Generated on Mon Nov 18 12:36:19 CET 2013
#
#####################################################################################


#Set time scale
set_global_assignment -name EDA_TIME_SCALE "1 ns" -section_id eda_simulation

#Set eda netlist writer options
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VHDL" -section_id eda_simulation

#Set to work in test bench mode
set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation

#Set testbench top level name and module name
set_global_assignment -name EDA_NATIVELINK_SIMULATION_TEST_BENCH esoc_port_mac_tb -section_id eda_simulation
set_global_assignment -name EDA_TEST_BENCH_NAME esoc_port_mac_tb -section_id eda_simulation
set_global_assignment -name EDA_TEST_BENCH_MODULE_NAME tb -section_id esoc_port_mac_tb

#Set design instance
set_global_assignment -name EDA_DESIGN_INSTANCE_NAME esoc_port_mac -section_id esoc_port_mac_tb

#Set simulation time
set_global_assignment -name EDA_TEST_BENCH_RUN_SIM_FOR "50 us" -section_id esoc_port_mac_tb

#Set testbench component files
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/ethgen.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/ethgen2.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/ethgen32.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/ethmon.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/ethmon2.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/ethmon_32.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/top_ethmon32.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/mdio_reg.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/mdio_slave.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/top_mdio_slave.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/loopback_adapter.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/loopback_adapter_fifo.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/timing_adapter_8.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/timing_adapter_fifo_8.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/timing_adapter_32.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/top_ethgen8.vhd -section_id esoc_port_mac_tb
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/model/altera_ethmodels_pack.vhd -section_id esoc_port_mac_tb

#Set memory initialization files
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/esoc_port_mac/sdpm_altsyncram.hex -section_id esoc_port_mac_tb

#Set top level testbench files
set_global_assignment -name EDA_TEST_BENCH_FILE testbench/esoc_port_mac/esoc_port_mac_tb.vhd -section_id esoc_port_mac_tb

