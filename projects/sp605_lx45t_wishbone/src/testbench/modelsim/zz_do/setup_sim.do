#
#
quit -sim
#
#
echo Cre WORK lib (and del OLD, if exists)
if {[file exists "work"]} { vdel -all}
vlib work

#
#
echo Compile SRC:

# provide typedef for shadow-ram
vcom -quiet ../../../src/pcie_src/components/rtl/host_pkg.vhd
# shadow-ram
vcom -quiet ../../../src/pcie_src/components/rtl/ctrl_ram16_v1.vhd

# WB_CROSS

vlog -quiet ../../../src/wishbone/cross/wb_conmax_arb.v
vlog -quiet ../../../src/wishbone/cross/wb_conmax_master_if.v
vlog -quiet ../../../src/wishbone/cross/wb_conmax_msel.v
vlog -quiet ../../../src/wishbone/cross/wb_conmax_pri_dec.v
vlog -quiet ../../../src/wishbone/cross/wb_conmax_pri_enc.v
vlog -quiet ../../../src/wishbone/cross/wb_conmax_rf.v
vlog -quiet ../../../src/wishbone/cross/wb_conmax_slave_if.v
vlog -quiet ../../../src/wishbone/cross/wb_conmax_top.v
vcom -quiet ../../../src/wishbone/cross/wb_conmax_top_pkg.vhd

# CORE64_M6
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_ctrl/core64_type_pkg.vhd
vcom -quiet ../../../src/pcie_src/components/coregen/ctrl_fifo64x37st.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_ctrl/core64_rx_engine_m4.vhd
vcom -quiet ../../../src/pcie_src/components/coregen/ctrl_fifo64x34fw.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_ctrl/core64_tx_engine_m4.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_ctrl/core64_reg_access.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_ctrl/core64_pb_disp.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_ctrl/core64_interrupt.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_fifo_ext/ctrl_dma_adr.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_fifo_ext/ctrl_dma_ext_cmd.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_fifo_ext/ctrl_ext_descriptor.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_fifo_ext/ctrl_ram_cmd_pb.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_fifo_ext/ctrl_ram_cmd.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_fifo_ext/ctrl_ext_ram.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_fifo_ext/ctrl_main.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_fifo_ext/block_pe_fifo_ext.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_s6/pcie_bram_s6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_s6/pcie_brams_s6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_s6/pcie_bram_top_s6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_s6/gtpa1_dual_wrapper_tile.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_s6/gtpa1_dual_wrapper.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_s6/cl_s6pcie_m2.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/top/pcie_core64_m6.vhd

# PE_MAIN
vcom -quiet ../../../src/pcie_src/components/block_main/block_pe_main.vhd

# PB<->WB bridge Logic
vcom -quiet ../../../src/pcie_src/components/coregen/ctrl_fifo512x64st_v0.vhd
vlog -quiet ../../../src/pcie_src/components/rtl/core64_pb_wishbone_ctrl.v


# PB_WB
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_ctrl/core64_type_pkg.vhd
vcom -quiet ../../../src/pcie_src/components/rtl/core64_pb_wishbone.vhd

# CORE64_M6+PE_MAIN+PB_WB_BRIDGE wrappper
vcom -quiet ../../../src/pcie_src/components/pcie_core/pcie_core64_wishbone.vhd

# TEST_CHECK
vcom -quiet ../../../src/wishbone/block_test_check/cl_test_check.vhd
vlog -quiet ../../../src/wishbone/block_test_check/block_check_wb_burst_slave.v
vcom -quiet ../../../src/wishbone/block_test_check/block_check_wb_config_slave.vhd
vcom -quiet ../../../src/wishbone/block_test_check/block_check_wb_pkg.vhd
vcom -quiet ../../../src/wishbone/block_test_check/block_test_check_wb.vhd

# TEST_GEN
vcom -quiet ../../../src/wishbone/coregen/ctrl_fifo1024x64_st_v1.vhd
vcom -quiet ../../../src/wishbone/block_test_generate/cl_test_generate.vhd
vlog -quiet ../../../src/wishbone/block_test_generate/block_generate_wb_burst_slave.v
vcom -quiet ../../../src/wishbone/block_test_generate/block_generate_wb_config_slave.vhd
vcom -quiet ../../../src/wishbone/block_test_generate/block_generate_wb_pkg.vhd
vcom -quiet ../../../src/wishbone/block_test_generate/block_test_generate_wb.vhd

# WB complete SOPC 
vcom -quiet ../../../src/top/sp605_lx45t_wishbone_sopc_wb.vhd

# Design TOP
vcom -quiet ../../../src/top/sp605_lx45t_wishbone.vhd

#
#
echo Compile TEST ENV:
vcom -quiet ../../../src/pcie_src/pcie_sim/sim/cmd_sim_pkg.vhd
vcom -quiet ../../../src/pcie_src/pcie_sim/sim/block_pkg.vhd
vcom -quiet ../../../src/pcie_src/pcie_sim/sim/trd_pcie_pkg.vhd

vcom -quiet ../../../src/pcie_src/pcie_sim/sim/root_memory_pkg.vhd
vcom -quiet ../../../src/pcie_src/pcie_sim/dsport/test_interface.vhd
vcom -quiet ../../../src/pcie_src/pcie_sim/dsport/pci_exp_usrapp_tx_m2.vhd
vcom -quiet ../../../src/pcie_src/pcie_sim/dsport/pci_exp_usrapp_rx_m2.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_reset_delay_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_clocking_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_pipe_misc_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_pipe_lane_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_pipe_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/gtx_drp_chanalign_fix_3752_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/gtx_rx_valid_filter_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/gtx_tx_sync_rate_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/gtx_wrapper_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_gtx_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_bram_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_brams_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_bram_top_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_upconfig_fix_3451_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_sim/dsport/pcie_2_0_v6_rp.vhd
vcom -quiet ../../../src/pcie_src/pcie_sim/dsport/pcie_2_0_rport_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_sim/dsport/pci_exp_usrapp_cfg.vhd
vcom -quiet ../../../src/pcie_src/pcie_sim/dsport/pci_exp_usrapp_pl.vhd
vcom -quiet ../../../src/pcie_src/pcie_sim/dsport/xilinx_pcie_rport_m2.vhd

vcom -quiet ../../../src/testbench/wb_block_pkg.vhd
vcom -quiet ../../../src/testbench/test_pkg.vhd
vcom -quiet ../../../src/testbench/stend_sp605_wishbone.vhd

#vlog -quiet glbl.v

#
#
echo Start SIM:
 vsim -t ps -novopt work.stend_sp605_wishbone
#vsim -t ps work.stend_sp605_wishbone

#
#
#log -r /*

#
#
#do wave.do

#
# skip warnings like: Warning: There is an 'U'|'X'|'W'|'Z'|'-' in an arithmetic operand, the result will be 'X'(es).
quietly set StdArithNoWarnings   1
quietly set NumericStdNoWarnings 1

#
#
 run -all
