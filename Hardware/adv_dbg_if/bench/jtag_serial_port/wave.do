onerror {resume}
quietly WaveActivateNextPane {} 0
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
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_rst_i
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
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/wb_jsp_adr_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/wb_jsp_dat_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/wb_jsp_dat_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_jsp_cyc_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_jsp_stb_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/wb_jsp_sel_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_jsp_we_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_jsp_ack_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_jsp_cab_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/wb_jsp_err_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/wb_jsp_cti_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/wb_jsp_bte_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/int_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/tdo_wb
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/tdo_cpu0
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/tdo_cpu1
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/tdo_jsp
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/input_shift_reg
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/module_id_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/select_cmd
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/module_id_in
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/module_selects
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/select_inhibit
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/module_inhibit
add wave -noupdate -divider {JSP Module}
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/tck_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/module_tdo_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/tdi_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/capture_dr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/shift_dr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/update_dr_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/data_register_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/module_select_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/top_inhibit_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/rst_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_clk_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_rst_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_adr_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_dat_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_dat_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_cyc_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_stb_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_sel_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_we_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_ack_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_cab_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_err_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_cti_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/wb_bte_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/int_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/read_bit_count
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/write_bit_count
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/input_word_count
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/output_word_count
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/user_word_count
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/data_out_shift_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/rd_bit_ct_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/rd_bit_ct_rst
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/wr_bit_ct_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/wr_bit_ct_rst
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/in_word_ct_sel
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/out_word_ct_sel
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/in_word_ct_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/out_word_ct_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/user_word_ct_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/user_word_ct_sel
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/out_reg_ld_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/out_reg_shift_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/out_reg_data_sel
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/biu_rd_strobe
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/biu_wr_strobe
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/in_word_count_zero
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/out_word_count_zero
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/user_word_count_zero
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/rd_bit_count_max
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/wr_bit_count_max
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/data_to_in_word_counter
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/data_to_out_word_counter
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/data_to_user_word_counter
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/decremented_in_word_count
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/decremented_out_word_count
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/decremented_user_word_count
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/count_data_in
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/data_to_biu
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/data_from_biu
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/biu_space_available
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/biu_bytes_available
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/count_data_from_biu
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/out_reg_data
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/rd_module_state
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/rd_module_next_state
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/wr_module_state
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/wr_module_next_state
add wave -noupdate -divider {JSP BIU}
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/tck_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rst_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/data_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/data_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/bytes_free_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/bytes_available_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_strobe_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_strobe_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_clk_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_rst_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_adr_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_dat_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_dat_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_cyc_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_stb_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_sel_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_we_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_ack_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_err_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/int_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/data_in
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rdata
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wen_tff
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/ren_tff
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_fifo_ack
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_bytes_free
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_bytes_avail
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_bytes_avail
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_bytes_avail_not_zero
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/ren_sff_out
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo_data_out
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/data_to_wb
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/data_from_wb
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo_not_empty
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wda_rst
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wpp
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/w_fifo_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/ren_rst
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rdata_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rpp
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/r_fifo_en
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/r_wb_ack
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/w_wb_ack
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wdata_avail
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_rd
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_wr
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/pop
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rcz
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fsm_state
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/next_rd_fsm_state
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fsm_state
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/next_wr_fsm_state
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/bus_data_lo
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/bus_data_hi
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wb_reg_ack
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo_not_full
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/reg_dlab_bit
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/reg_ier
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/reg_iir
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/thr_int_arm
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/reg_lsr
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/reg_dlab_bit_wren
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/reg_ier_wren
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/reg_iir_rden
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/reg_lcr
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/reg_fcr_wren
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rcvr_fifo_rst
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/xmit_fifo_rst
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/reg_mcr
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/reg_msr
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/reg_scr
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/iir_gen
add wave -noupdate -divider {WR FIFO}
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/CLK
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/RST
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/DATA_IN
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/DATA_OUT
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/PUSH_POPn
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/EN
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/BYTES_AVAIL
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/BYTES_FREE
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/reg0
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/reg1
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/reg2
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/reg3
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/reg4
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/reg5
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/reg6
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/reg7
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/counter
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/push_ok
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/wr_fifo/pop_ok
add wave -noupdate -divider {RD FIFO}
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/CLK
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/RST
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/DATA_IN
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/DATA_OUT
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/PUSH_POPn
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/EN
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/BYTES_AVAIL
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/BYTES_FREE
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/reg0
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/reg1
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/reg2
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/reg3
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/reg4
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/reg5
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/reg6
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/reg7
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/counter
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/push_ok
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_jsp/jsp_biu_i/rd_fifo/pop_ok
add wave -noupdate -divider {WB Module}
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/tck_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/module_tdo_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/tdi_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/capture_dr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/shift_dr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/update_dr_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/data_register_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/module_select_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/top_inhibit_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/rst_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_clk_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_adr_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_dat_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_dat_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_cyc_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_stb_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_sel_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_we_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_ack_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_cab_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_err_i
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_cti_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_bte_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/address_counter
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/bit_count
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/word_count
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/operation
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/data_out_shift_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/internal_register_select
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/internal_reg_error
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
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/word_size_bits
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/word_size_bytes
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/incremented_address
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/data_to_addr_counter
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/data_to_word_counter
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/decremented_word_count
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/address_data_in
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/count_data_in
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/operation_in
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/data_to_biu
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/data_from_biu
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/crc_data_out
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/crc_data_in
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/crc_serial_out
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/reg_select_data
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/out_reg_data
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/data_from_internal_reg
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/biu_rst
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/module_state
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/module_next_state
add wave -noupdate -divider {WB BIU}
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/tck_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/rst_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/data_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/data_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/addr_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/strobe_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/rd_wrn_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/rdy_o
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/err_o
add wave -noupdate -format Literal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/word_size_i
add wave -noupdate -format Logic /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_clk_i
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_adr_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_dat_o
add wave -noupdate -format Literal -radix hexadecimal /adv_debug_tb/i_dbg_module/i_dbg_wb/wb_biu_i/wb_dat_i
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
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {553794 ns} 0}
configure wave -namecolwidth 466
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
configure wave -timelineunits ns
update
WaveRestoreZoom {391982 ns} {400422 ns}
