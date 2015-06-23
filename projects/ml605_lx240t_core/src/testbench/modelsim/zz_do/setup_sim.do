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

vcom -quiet ../../../src/adm/adm2_pkg.vhd

vcom -quiet ../../../src/adm/cl_ambpex5/rtl/ctrl_adsp_v2_decode_data_cs.vhd
vcom -quiet ../../../src/adm/cl_ambpex5/rtl/ctrl_adsp_v2_decode_data_we.vhd
vcom -quiet ../../../src/adm/cl_ambpex5/rtl/ctrl_adsp_v2_decode_ram_cs.vhd
vcom -quiet ../../../src/adm/cl_ambpex5/rtl/ctrl_adsp_v2_decode_cmd_adr_cs.vhd
vcom -quiet ../../../src/adm/coregen/ctrl_mux8x48.vhd
vcom -quiet ../../../src/adm/coregen/ctrl_mux16x16.vhd
vcom -quiet ../../../src/adm/coregen/ctrl_mux8x16r.vhd
vcom -quiet ../../../src/adm/cl_ambpex5/rtl/pb_adm_ctrl_m2.vhd
vcom -quiet ../../../src/adm/cl_ambpex5/rtl/ctrl_blink.vhd

vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_ctrl/core64_type_pkg.vhd
vcom -quiet ../../../src/pcie_src/components/coregen/ctrl_fifo64x70st.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_ctrl/core64_rx_engine_m2.vhd
vcom -quiet ../../../src/pcie_src/components/coregen/ctrl_fifo64x67fw.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/pcie_ctrl/core64_tx_engine_m2.vhd
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

vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/axi_basic_rx_null_gen.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/axi_basic_rx_pipeline.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/axi_basic_rx.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/axi_basic_tx_pipeline.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/axi_basic_tx_thrtl_ctl.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/axi_basic_tx.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/axi_basic_top.vhd

vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_pipe_lane_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_pipe_misc_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_pipe_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/gtx_drp_chanalign_fix_3752_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/gtx_rx_valid_filter_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/gtx_tx_sync_rate_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/gtx_wrapper_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_gtx_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_brams_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_bram_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_bram_top_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_upconfig_fix_3451_v6.vhd
vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/pcie_2_0_v6.vhd

vcom -quiet ../../../src/pcie_src/pcie_core64_m1/source_virtex6/cl_v6pcie_x4.vhd

vcom -quiet ../../../src/pcie_src/pcie_core64_m1/top/pcie_core64_m4.vhd
vcom -quiet ../../../src/pcie_src/components/rtl/core64_pb_transaction.vhd
vcom -quiet ../../../src/pcie_src/components/rtl/host_pkg.vhd
vcom -quiet ../../../src/pcie_src/components/rtl/ctrl_ram16_v1.vhd
vcom -quiet ../../../src/pcie_src/components/block_main/block_pe_main.vhd
vcom -quiet ../../../src/pcie_src/components/pcie_core/pcie_core64_m5.vhd
vcom -quiet ../../../src/adm/cl_ml605/top/cl_ml605.vhd

vcom -quiet ../../../src/adm/rtl/ctrl_start_v2.vhd
vcom -quiet ../../../src/adm/main/cl_test0_v4.vhd
vcom -quiet ../../../src/adm/main/ctrl_thdac.vhd
vcom -quiet ../../../src/adm/main/trd_main_v8.vhd

vcom -quiet ../../../src/adm/main/trd_pio_std_v4.vhd

vcom -quiet ../../../src/adm/main/cl_chn_v3.vhd
vcom -quiet ../../../src/adm/main/cl_chn_v4.vhd
vcom -quiet ../../../src/adm/coregen/ctrl_fifo1024x65_v5.vhd
vcom -quiet ../../../src/adm/rtl/cl_fifo_control_v2.vhd
vcom -quiet ../../../src/adm/rtl/cl_fifo1024x65_v5.vhd
vcom -quiet ../../../src/adm/dio64/trd_admdio64_out_v4.vhd
vcom -quiet ../../../src/adm/core_s3_empty/ctrl_buft16.vhd
vcom -quiet ../../../src/adm/core_s3_empty/ctrl_buft64.vhd
vcom -quiet ../../../src/adm/dio64/trd_admdio64_in_v6.vhd

vcom -quiet ../../../src/adm/main/cl_test_generate.vhd
vcom -quiet ../../../src/adm/main/cl_test_check.vhd
vcom -quiet ../../../src/adm/coregen/ctrl_multiplier_v1_0.vhd
vcom -quiet ../../../src/adm/trd_test_ctrl/ctrl_freq.vhd
vcom -quiet ../../../src/adm/trd_test_ctrl/trd_test_ctrl_m1.vhd

vcom -quiet ../../../src/top/ml605_lx240t_core.vhd


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

vcom -quiet ../../../src/testbench/test_pkg.vhd
vcom -quiet ../../../src/testbench/stend_ml605_core_m2.vhd

#
#
echo Start SIM:
 vsim -t ps -novopt work.stend_ml605_core_m2

#
#
#log -r /*

#
#
#do wave_1.do
 do wave.do

#
# skip warnings like: Warning: There is an 'U'|'X'|'W'|'Z'|'-' in an arithmetic operand, the result will be 'X'(es).
quietly set StdArithNoWarnings   1
quietly set NumericStdNoWarnings 1

#
#
 run -all
