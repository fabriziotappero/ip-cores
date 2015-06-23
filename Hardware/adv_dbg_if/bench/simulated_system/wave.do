onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {JTAG top}
add wave -noupdate -format Logic /adv_debug_tb/jtag_tck_o
add wave -noupdate -format Logic /adv_debug_tb/jtag_tms_o
add wave -noupdate -format Logic /adv_debug_tb/jtag_tdo_o
add wave -noupdate -format Logic /adv_debug_tb/jtag_tdi_i
add wave -noupdate -divider {TAP signals}
add wave -noupdate -format Logic /adv_debug_tb/dbg_rst
add wave -noupdate -format Logic /adv_debug_tb/capture_dr
add wave -noupdate -format Logic /adv_debug_tb/shift_dr
add wave -noupdate -format Logic /adv_debug_tb/pause_dr
add wave -noupdate -format Logic /adv_debug_tb/update_dr
add wave -noupdate -format Logic /adv_debug_tb/dbg_sel
add wave -noupdate -format Logic /adv_debug_tb/dbg_tdi
add wave -noupdate -format Logic /adv_debug_tb/dbg_tdo
add wave -noupdate -divider {Wishbone signals}
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/wb_adr
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/wb_dat_m
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/wb_dat_s
add wave -noupdate -format Logic /adv_debug_tb/wb_cyc
add wave -noupdate -format Logic /adv_debug_tb/wb_stb
add wave -noupdate -format Literal /adv_debug_tb/wb_sel
add wave -noupdate -format Logic /adv_debug_tb/wb_we
add wave -noupdate -format Logic /adv_debug_tb/wb_ack
add wave -noupdate -format Logic /adv_debug_tb/wb_err
add wave -noupdate -format Logic /adv_debug_tb/wb_clk_i
add wave -noupdate -format Logic /adv_debug_tb/wb_rst_i
add wave -noupdate -divider {CPU0 signals}
add wave -noupdate -format Logic /adv_debug_tb/cpu0_clk
add wave -noupdate -format Logic /adv_debug_tb/cpu0_rst
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/cpu0_addr
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/cpu0_data_c
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/cpu0_data_d
add wave -noupdate -format Logic /adv_debug_tb/cpu0_we
add wave -noupdate -format Logic /adv_debug_tb/cpu0_stb
add wave -noupdate -format Logic /adv_debug_tb/cpu0_ack
add wave -noupdate -format Logic /adv_debug_tb/cpu0_bp
add wave -noupdate -format Logic /adv_debug_tb/cpu0_stall
add wave -noupdate -divider {Debug top internals}
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/tck_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/tdi_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/tdo_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/rst_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/shift_dr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/pause_dr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/update_dr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/capture_dr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/debug_select_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_clk_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/wb_adr_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/wb_dat_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/wb_dat_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_cyc_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_stb_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/wb_sel_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_we_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_ack_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_cab_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_err_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/wb_cti_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/wb_bte_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/cpu0_clk_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/cpu0_addr_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/cpu0_data_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/cpu0_data_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/cpu0_bp_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/cpu0_stall_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/cpu0_stb_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/cpu0_we_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/cpu0_ack_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/cpu0_rst_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/input_shift_reg
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/module_id_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/select_cmd
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/module_id_in
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/module_selects
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/tdo_wb
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/tdo_cpu0
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/tdo_cpu1
add wave -noupdate -divider {DBG Wishbone module internals}
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/tck_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/module_tdo_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/tdi_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/capture_dr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/shift_dr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/update_dr_i
add wave -noupdate -format Literal -radix binary /adv_debug_tb/i_dbg_module/i_dbg_wb/data_register_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/module_select_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/rst_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_clk_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_adr_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_dat_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_dat_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_cyc_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_stb_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_sel_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_we_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_ack_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_cab_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_err_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_cti_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_bte_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/address_counter
add wave -noupdate -format Literal -radix decimal /adv_debug_tb/i_dbg_module/i_dbg_wb/bit_count
add wave -noupdate -format Literal -radix decimal /adv_debug_tb/i_dbg_module/i_dbg_wb/word_count
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/operation
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/data_out_shift_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/internal_register_select
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/internal_reg_error
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/addr_sel
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/addr_ct_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/op_reg_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/bit_ct_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/bit_ct_rst
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/word_ct_sel
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/word_ct_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/out_reg_ld_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/out_reg_shift_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/out_reg_data_sel
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/tdo_output_sel
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/biu_strobe
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/crc_clr
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/crc_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/crc_in_sel
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/crc_shift_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/regsel_ld_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/intreg_ld_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/error_reg_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/biu_clr_err
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/word_count_zero
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/bit_count_max
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/module_cmd
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/biu_ready
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/biu_err
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/burst_instruction
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/intreg_instruction
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/intreg_write
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/rd_op
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/crc_match
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/bit_count_32
add wave -noupdate -format Literal -radix decimal /adv_debug_tb/i_dbg_module/i_dbg_wb/word_size_bits
add wave -noupdate -format Literal -radix decimal /adv_debug_tb/i_dbg_module/i_dbg_wb/word_size_bytes
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/incremented_address
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/data_to_addr_counter
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/data_to_word_counter
add wave -noupdate -format Literal -radix decimal /adv_debug_tb/i_dbg_module/i_dbg_wb/decremented_word_count
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/address_data_in
add wave -noupdate -format Literal -radix decimal /adv_debug_tb/i_dbg_module/i_dbg_wb/count_data_in
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/operation_in
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/data_to_biu
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/data_from_biu
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/crc_data_out
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/crc_data_in
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/crc_serial_out
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/reg_select_data
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/out_reg_data
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/data_from_internal_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/biu_rst
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/module_state
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/module_next_state
add wave -noupdate -divider {DBG WB module BIU internals}
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/tck_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/rst_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/data_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/data_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/addr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/strobe_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/rd_wrn_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/rdy_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/err_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/word_size_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_clk_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_adr_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_dat_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_dat_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_cyc_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_stb_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_sel_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_we_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_ack_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_cab_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_err_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_cti_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_bte_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/sel_reg
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/addr_reg
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/data_in_reg
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/data_out_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wr_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/str_sync
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/rdy_sync
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/err_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/rdy_sync_tff1
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/rdy_sync_tff2
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/rdy_sync_tff2q
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/str_sync_wbff1
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/str_sync_wbff2
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/str_sync_wbff2q
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/data_o_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/rdy_sync_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/err_en
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/be_dec
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/start_toggle
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/swapped_data_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/swapped_data_out
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_fsm_state
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/next_fsm_state
add wave -noupdate -divider {DBG CPU0 module signals}
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/tck_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/module_tdo_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/tdi_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/capture_dr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/shift_dr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/update_dr_i
add wave -noupdate -format Literal -radix binary /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/data_register_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/module_select_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/rst_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/cpu_clk_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/cpu_addr_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/cpu_data_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/cpu_data_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/cpu_stb_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/cpu_we_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/cpu_ack_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/cpu_rst_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/cpu_bp_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/cpu_stall_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/address_counter
add wave -noupdate -format Literal -radix decimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/bit_count
add wave -noupdate -format Literal -radix decimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/word_count
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/operation
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/data_out_shift_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/internal_register_select
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/internal_reg_status
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/addr_sel
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/addr_ct_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/op_reg_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/bit_ct_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/bit_ct_rst
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/word_ct_sel
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/word_ct_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/out_reg_ld_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/out_reg_shift_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/out_reg_data_sel
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/tdo_output_sel
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/biu_strobe
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/crc_clr
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/crc_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/crc_in_sel
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/crc_shift_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/regsel_ld_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/intreg_ld_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/word_count_zero
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/bit_count_max
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/module_cmd
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/biu_ready
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/burst_instruction
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/intreg_instruction
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/intreg_write
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/rd_op
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/crc_match
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/bit_count_32
add wave -noupdate -format Literal -radix decimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/word_size_bits
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/incremented_address
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/data_to_addr_counter
add wave -noupdate -format Literal -radix decimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/data_to_word_counter
add wave -noupdate -format Literal -radix decimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/decremented_word_count
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/address_data_in
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/count_data_in
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/operation_in
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/data_to_biu
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/data_from_biu
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/crc_data_out
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/crc_data_in
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/crc_serial_out
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/reg_select_data
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/out_reg_data
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/data_from_internal_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/status_reg_wr
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/module_state
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/module_next_state
add wave -noupdate -divider {CPU0 BIU internals}
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/tck_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/rst_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/data_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/data_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/addr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/strobe_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/rd_wrn_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/rdy_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/cpu_clk_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/cpu_addr_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/cpu_data_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/cpu_data_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/cpu_stb_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/cpu_we_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/cpu_ack_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/addr_reg
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/data_in_reg
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/data_out_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/wr_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/str_sync
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/rdy_sync
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/rdy_sync_tff1
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/rdy_sync_tff2
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/rdy_sync_tff2q
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/str_sync_wbff1
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/str_sync_wbff2
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/str_sync_wbff2q
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/data_o_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/rdy_sync_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/start_toggle
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/cpu_fsm_state
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_cpu_or1k/or1k_biu_i/next_fsm_state
add wave -noupdate -divider {CPU0 Status register internals}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {31260960 ps} 0}
configure wave -namecolwidth 409
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
WaveRestoreZoom {38962 ns} {70222960 ps}
