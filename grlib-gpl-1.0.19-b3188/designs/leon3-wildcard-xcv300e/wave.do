onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider External
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/clocks_f_clk
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/clocks_m_clk
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/clocks_p_clk
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/clocks_k_clk
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/clocks_io_clk
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/clocks_m_clk_out_pe
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/clocks_m_clk_out_cb_ctrl
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/clocks_m_clk_out_right_mem
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/clocks_m_clk_out_left_mem
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/clocks_p_clk_out_pe
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/clocks_p_clk_out_cb_ctrl
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/reset_reset
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/audio_audio
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/lad_bus_addr_data
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_as_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_ds_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_wr_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_cs_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_reg_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_ack_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_int_req_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_dma_0_data_ok_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_dma_0_burst_ok
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_dma_1_data_ok_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_dma_1_burst_ok
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_reg_data_ok_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_reg_burst_ok
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_force_k_clk_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/lad_bus_reserved
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/left_mem_addr
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/left_mem_data
add wave -noupdate -format Literal /system/u_wildcard/u_pe/fpga/left_mem_byte_wr_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/left_mem_cs_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/left_mem_ce_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/left_mem_we_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/left_mem_oe_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/left_mem_sleep_en
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/left_mem_load_en_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/left_mem_burst_mode
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/right_mem_addr
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/right_mem_data
add wave -noupdate -format Literal /system/u_wildcard/u_pe/fpga/right_mem_byte_wr_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/right_mem_cs_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/right_mem_ce_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/right_mem_we_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/right_mem_oe_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/right_mem_sleep_en
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/right_mem_load_en_n
add wave -noupdate -format Logic /system/u_wildcard/u_pe/fpga/right_mem_burst_mode
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/left_io
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/right_io
add wave -noupdate -divider Amba
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/ladi
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/lado
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/apbi
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/apbo
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/ahbso
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/ahbmi
add wave -noupdate -format Literal -radix hexadecimal /system/u_wildcard/u_pe/fpga/ahbmo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {43611000 ps} 0}
configure wave -namecolwidth 222
configure wave -valuecolwidth 115
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ps} {40983991 ps}
