onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /xsv_fpga_top/jtag_tdi
add wave -noupdate -format Logic /xsv_fpga_top/jtag_tms
add wave -noupdate -format Logic /xsv_fpga_top/jtag_tck
add wave -noupdate -format Logic /xsv_fpga_top/jtag_tdo
add wave -noupdate -format Logic /xsv_fpga_top/debug_select
add wave -noupdate -divider {Top level signals}
add wave -noupdate -format Logic /xsv_fpga_top/clk
add wave -noupdate -format Logic /xsv_fpga_top/rstn
add wave -noupdate -format Logic /xsv_fpga_top/rst_r
add wave -noupdate -format Logic /xsv_fpga_top/wb_rst
add wave -noupdate -format Logic /xsv_fpga_top/cpu_rst
add wave -noupdate -divider {Top-level CPU dbg}
add wave -noupdate -format Literal /xsv_fpga_top/dbg_lss
add wave -noupdate -format Literal /xsv_fpga_top/dbg_is
add wave -noupdate -format Literal /xsv_fpga_top/dbg_wp
add wave -noupdate -format Logic /xsv_fpga_top/dbg_bp
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/dbg_dat_dbg
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/dbg_dat_risc
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/dbg_adr
add wave -noupdate -format Logic /xsv_fpga_top/dbg_ewt
add wave -noupdate -format Logic /xsv_fpga_top/dbg_stall
add wave -noupdate -format Logic /xsv_fpga_top/dbg_we
add wave -noupdate -format Logic /xsv_fpga_top/dbg_stb
add wave -noupdate -format Logic /xsv_fpga_top/dbg_ack
add wave -noupdate -divider {CPU IWB}
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/iwb_clk_i
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/iwb_rst_i
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/iwb_ack_i
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/iwb_err_i
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/iwb_rty_i
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/or1200_top/iwb_dat_i
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/iwb_cyc_o
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/or1200_top/iwb_adr_o
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/iwb_stb_o
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/iwb_we_o
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/iwb_sel_o
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/or1200_top/iwb_dat_o
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/iwb_cab_o
add wave -noupdate -divider {DBG WB signals}
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/wb_dm_adr_o
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/wb_dm_dat_i
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/wb_dm_dat_o
add wave -noupdate -format Literal /xsv_fpga_top/wb_dm_sel_o
add wave -noupdate -format Logic /xsv_fpga_top/wb_dm_we_o
add wave -noupdate -format Logic /xsv_fpga_top/wb_dm_stb_o
add wave -noupdate -format Logic /xsv_fpga_top/wb_dm_cyc_o
add wave -noupdate -format Logic /xsv_fpga_top/wb_dm_cab_o
add wave -noupdate -format Logic /xsv_fpga_top/wb_dm_ack_i
add wave -noupdate -format Logic /xsv_fpga_top/wb_dm_err_i
add wave -noupdate -divider {DBG WB BIU}
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/tck_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/rst_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/data_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/data_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/addr_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/strobe_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/rd_wrn_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/rdy_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/err_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/word_size_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_clk_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_adr_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_dat_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_dat_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_cyc_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_stb_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_sel_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_we_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_ack_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_cab_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_err_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_cti_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_bte_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/sel_reg
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/addr_reg
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/data_in_reg
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/data_out_reg
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wr_reg
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/str_sync
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/rdy_sync
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/err_reg
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/rdy_sync_tff1
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/rdy_sync_tff2
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/rdy_sync_tff2q
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/str_sync_wbff1
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/str_sync_wbff2
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/str_sync_wbff2q
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/data_o_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/rdy_sync_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/err_en
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/be_dec
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/start_toggle
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/swapped_data_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/swapped_data_out
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/wb_fsm_state
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_biu_i/next_fsm_state
add wave -noupdate -divider {DBG WB Module}
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/tck_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/module_tdo_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/tdi_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/capture_dr_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/shift_dr_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/update_dr_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/data_register_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/module_select_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/top_inhibit_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/rst_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_clk_i
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_adr_o
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_dat_o
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_dat_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_cyc_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_stb_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_sel_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_we_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_ack_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_cab_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/wb_err_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_cti_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/wb_bte_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/address_counter
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/bit_count
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/word_count
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/operation
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/data_out_shift_reg
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/internal_register_select
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/internal_reg_error
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/addr_sel
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/addr_ct_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/op_reg_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/bit_ct_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/bit_ct_rst
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/word_ct_sel
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/word_ct_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/out_reg_ld_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/out_reg_shift_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/out_reg_data_sel
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/tdo_output_sel
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/biu_strobe
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/crc_clr
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/crc_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/crc_in_sel
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/crc_shift_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/regsel_ld_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/intreg_ld_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/error_reg_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/biu_clr_err
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/word_count_zero
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/bit_count_max
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/module_cmd
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/biu_ready
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/biu_err
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/burst_instruction
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/intreg_instruction
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/intreg_write
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/rd_op
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/crc_match
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/bit_count_32
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/word_size_bits
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/word_size_bytes
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/incremented_address
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/data_to_addr_counter
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/data_to_word_counter
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/decremented_word_count
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/address_data_in
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/count_data_in
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/operation_in
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/data_to_biu
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/data_from_biu
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/crc_data_out
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/crc_data_in
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/crc_serial_out
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/reg_select_data
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/out_reg_data
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/data_from_internal_reg
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_wb/biu_rst
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/module_state
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_wb/module_next_state
add wave -noupdate -divider {DBG Top}
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/tck_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/tdi_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/tdo_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/rst_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/shift_dr_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/pause_dr_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/update_dr_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/capture_dr_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/debug_select_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/wb_clk_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/wb_adr_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/wb_dat_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/wb_dat_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/wb_cyc_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/wb_stb_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/wb_sel_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/wb_we_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/wb_ack_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/wb_cab_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/wb_err_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/wb_cti_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/wb_bte_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/cpu0_clk_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/cpu0_addr_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/cpu0_data_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/cpu0_data_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/cpu0_bp_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/cpu0_stall_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/cpu0_stb_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/cpu0_we_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/cpu0_ack_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/cpu0_rst_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/tdo_wb
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/tdo_cpu0
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/tdo_cpu1
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/input_shift_reg
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/module_id_reg
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/select_inhibit
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/module_inhibit
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/select_cmd
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/module_id_in
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/module_selects
add wave -noupdate -divider {DBG CPU0 Module}
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/tck_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/module_tdo_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/tdi_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/capture_dr_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/shift_dr_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/update_dr_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/data_register_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/module_select_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/top_inhibit_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/rst_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/cpu_clk_i
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/cpu_addr_o
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/cpu_data_i
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/cpu_data_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/cpu_stb_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/cpu_we_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/cpu_ack_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/cpu_rst_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/cpu_bp_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/cpu_stall_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/address_counter
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/bit_count
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/word_count
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/operation
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/data_out_shift_reg
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/internal_register_select
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/internal_reg_status
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/addr_sel
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/addr_ct_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/op_reg_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/bit_ct_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/bit_ct_rst
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/word_ct_sel
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/word_ct_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/out_reg_ld_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/out_reg_shift_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/out_reg_data_sel
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/tdo_output_sel
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/biu_strobe
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/crc_clr
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/crc_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/crc_in_sel
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/crc_shift_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/regsel_ld_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/intreg_ld_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/word_count_zero
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/bit_count_max
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/module_cmd
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/biu_ready
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/burst_instruction
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/intreg_instruction
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/intreg_write
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/rd_op
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/crc_match
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/bit_count_32
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/word_size_bits
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/address_increment
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/incremented_address
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/data_to_addr_counter
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/data_to_word_counter
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/decremented_word_count
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/address_data_in
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/count_data_in
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/operation_in
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/data_to_biu
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/data_from_biu
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/crc_data_out
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/crc_data_in
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/crc_serial_out
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/reg_select_data
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/out_reg_data
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/data_from_internal_reg
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/status_reg_wr
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/module_state
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/module_next_state
add wave -noupdate -divider {DBG CPU0 BIU}
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/tck_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/rst_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/data_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/data_o
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/addr_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/strobe_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/rd_wrn_i
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/rdy_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/cpu_clk_i
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/cpu_addr_o
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/cpu_data_i
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/cpu_data_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/cpu_stb_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/cpu_we_o
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/cpu_ack_i
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/addr_reg
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/data_in_reg
add wave -noupdate -format Literal /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/data_out_reg
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/wr_reg
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/str_sync
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/rdy_sync
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/rdy_sync_tff1
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/rdy_sync_tff2
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/rdy_sync_tff2q
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/str_sync_wbff1
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/str_sync_wbff2
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/str_sync_wbff2q
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/data_o_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/rdy_sync_en
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/start_toggle
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/cpu_fsm_state
add wave -noupdate -format Logic /xsv_fpga_top/dbg_top/i_dbg_cpu_or1k/or1k_biu_i/next_fsm_state
add wave -noupdate -divider {CPU debug unit}
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/clk
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/rst
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dcpu_cycstb_i
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dcpu_we_i
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dcpu_adr_i
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dcpu_dat_lsu
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dcpu_dat_dc
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/icpu_cycstb_i
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/ex_freeze
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/branch_op
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/ex_insn
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/id_pc
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/spr_dat_npc
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/rf_dataw
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/du_dsr
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/du_stall
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/du_addr
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/du_dat_i
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/du_dat_o
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/du_read
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/du_write
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/du_except
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/du_hwbkpt
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/spr_cs
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/spr_write
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/spr_addr
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/spr_dat_i
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/spr_dat_o
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dbg_stall_i
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dbg_ewt_i
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dbg_lss_o
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dbg_is_o
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dbg_wp_o
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dbg_bp_o
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dbg_stb_i
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dbg_we_i
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dbg_adr_i
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dbg_dat_i
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dbg_dat_o
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dbg_ack_o
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dmr1
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dmr2
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dsr
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/drr
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dvr0
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dvr1
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dvr2
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dvr3
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dvr4
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dvr5
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dvr6
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dvr7
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dcr0
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dcr1
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dcr2
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dcr3
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dcr4
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dcr5
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dcr6
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dcr7
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dwcr0
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/dwcr1
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dmr1_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dmr2_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dsr_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/drr_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dvr0_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dvr1_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dvr2_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dvr3_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dvr4_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dvr5_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dvr6_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dvr7_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dcr0_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dcr1_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dcr2_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dcr3_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dcr4_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dcr5_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dcr6_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dcr7_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dwcr0_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dwcr1_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_du/dbg_bp_r
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/except_stop
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/tbia_dat_o
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/tbim_dat_o
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/tbar_dat_o
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_du/tbts_dat_o
add wave -noupdate -divider {CPU SPRs}
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/clk
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/rst
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/flagforw
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/flag_we
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/flag
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/cyforw
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/cy_we
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/carry
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/addrbase
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/addrofs
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/dat_i
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/alu_op
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/branch_op
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/epcr
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/eear
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/esr
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/except_started
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/to_wbmux
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/epcr_we
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/eear_we
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/esr_we
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/pc_we
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/sr_we
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/to_sr
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/sr
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_dat_cfgr
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_dat_rf
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_dat_npc
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_dat_ppc
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_dat_mac
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_dat_pic
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_dat_tt
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_dat_pm
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_dat_dmmu
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_dat_immu
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_dat_du
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_addr
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_dat_o
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_cs
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/spr_we
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/du_addr
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/du_dat_du
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/du_read
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/du_write
add wave -noupdate -format Literal -radix hexadecimal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/du_dat_cpu
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/write_spr
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/read_spr
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/cfgr_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/rf_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/npc_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/ppc_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/sr_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/epcr_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/eear_sel
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/esr_sel
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/sys_data
add wave -noupdate -format Logic /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/du_access
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/sprs_op
add wave -noupdate -format Literal /xsv_fpga_top/or1200_top/or1200_cpu/or1200_sprs/unqualified_cs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4278 ps} 0}
configure wave -namecolwidth 391
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {6180 ps}
