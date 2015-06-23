onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/wb_clk
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/wb_rst
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/wb_int
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/mtx_clk
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/mrx_clk
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/MTxD
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/MTxEn
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/MTxErr
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/MRxD
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/MRxDV
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/MRxErr
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/MColl
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/MCrs
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/Mdi_I
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/Mdo_O
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/Mdo_OE
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/Mdio_IO
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/Mdc_O
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_sl_wb_adr
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_sl_wb_adr_i
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_sl_wb_dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_sl_wb_dat_i
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_sl_wb_sel_i
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_sl_wb_we_i
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_sl_wb_cyc_i
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_sl_wb_stb_i
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_sl_wb_ack_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_sl_wb_err_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_ma_wb_adr_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_ma_wb_dat_i
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_ma_wb_dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_ma_wb_sel_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_ma_wb_we_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_ma_wb_cyc_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_ma_wb_stb_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_ma_wb_ack_i
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_ma_wb_err_i
add wave -noupdate -format Logic -radix ascii /tb_ethernet/test_name
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/wbm_init_waits
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/wbm_subseq_waits
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/wbs_waits
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/wbs_retries

add wave -noupdate -format Logic -radix hex /tb_ethernet/ethmac/wishbone/*
add wave -noupdate -format Logic -radix decimal /tb_ethernet/test_mac_full_duplex_receive/i_length
add wave -noupdate -format Logic -radix decimal /tb_ethernet/test_mac_full_duplex_receive/num_of_bd
add wave -noupdate -format Logic -radix decimal /tb_ethernet/test_mac_full_duplex_transmit/max_tmp
add wave -noupdate -format Logic -radix decimal /tb_ethernet/test_mac_full_duplex_transmit/min_tmp
add wave -noupdate -format Logic -radix decimal /tb_ethernet/test_mac_full_duplex_transmit/i_length
add wave -noupdate -format Logic -radix decimal /tb_ethernet/test_mac_full_duplex_transmit/num_of_frames
add wave -noupdate -format Logic -radix decimal /tb_ethernet/test_mac_full_duplex_transmit/num_of_bd
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/wb_slave/calc_ack
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/wb_slave/a_e_r_resp
add wave -noupdate -format Logic -radix decimal /tb_ethernet/test_mac_full_duplex_transmit/frame_ended

add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/m_rst_n_i
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mtx_clk_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mtxd_i
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mtxen_i
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mtxerr_i
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mrx_clk_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mrxd_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mrxdv_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mrxerr_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mcoll_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mcrs_o
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mdc_i
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/md_io
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/phy_log
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/control_bit15
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/control_bit14_10
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/control_bit9
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/control_bit8_0
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/status_bit15_9
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/status_bit8
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/status_bit7
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/status_bit6_0
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/phy_id1
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/phy_id2
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/rx_link_down_halfperiod
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/eth_speed
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/respond_to_all_phy_addr
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/no_preamble
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/md_transfer_cnt
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/md_transfer_cnt_reset
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/md_io_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/md_io_output
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/md_io_rd_wr
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/md_io_enable
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/phy_address
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/reg_address
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/md_get_phy_address
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/md_get_reg_address
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/reg_data_in
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/md_get_reg_data_in
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/md_put_reg_data_in
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/reg_data_out
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/md_put_reg_data_out
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/register_bus_in
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/register_bus_out
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/registers_addr_data_test_operation
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/self_clear_d0
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/self_clear_d1
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/self_clear_d2
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/self_clear_d3
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mcrs_rx
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mcrs_tx
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/mtxen_d
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/task_mcoll
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/task_mcrs
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/task_mcrs_lost
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/no_collision_in_half_duplex
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/collision_in_full_duplex
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/no_carrier_sense_in_tx_half_duplex
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/no_carrier_sense_in_rx_half_duplex
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/carrier_sense_in_tx_full_duplex
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/no_carrier_sense_in_rx_full_duplex
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/real_carrier_sense
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/tx_mem_addr_in
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/tx_mem_data_in
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/tx_cnt
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/tx_preamble_ok
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/tx_sfd_ok
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/tx_byte_aligned_ok
add wave -noupdate -format Logic -radix hexadecimal /tb_ethernet/eth_phy/tx_len
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {476613 ns}
WaveRestoreZoom {476105 ns} {478586 ns}
configure wave -namecolwidth 280
configure wave -valuecolwidth 68
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
