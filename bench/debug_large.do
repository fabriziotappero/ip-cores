onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/TX_CLK
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/RESET
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/TX_START
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/TX_UNDERRUN
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/TX_ACK
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/FC_TRANS_PAUSEDATA
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/FC_TRANS_PAUSEVAL
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/FC_TX_PAUSEDATA
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/FC_TX_PAUSEVALID
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/FRAME_START
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/reset_int
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/DELAY_ACK
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_REG
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL1
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL2
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL3
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL4
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL5
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL6
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL7
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL8
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL9
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL10
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL11
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL12
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL13
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL14
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DEL15
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL1
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL2
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL3
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL4
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL5
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL6
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL7
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL8
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL9
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL10
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL11
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL12
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL13
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL14
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_DEL15
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/OVERFLOW_VALID
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/OVERFLOW_DATA
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_REG
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TX_DATA_VALID_DELAY
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/CRC_32_64
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/BYTE_COUNTER
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/frame_start_del
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/transmit_pause_frame_del
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/transmit_pause_frame
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/append_start_pause
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/append_start_pause_del
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/transmit_pause_frame_valid
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/reset_err_pause
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/load_CRC8
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/tx_data_int
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/start_CRC8
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/START_CRC8_DEL
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/append_end_frame
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/insert_error
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/store_tx_data_valid
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/store_tx_data
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/store_CRC64
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/store_valid
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/load_final_CRC
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/final_byte_count
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/byte_count_reg
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/CRC_OUT
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/append_reg
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/length_register
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/tx_undderrun_int
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/MAX_FRAME_SIZE
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/vlan_enabled_int
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/jumbo_enabled_int
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/tx_enabled_int
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/fcs_enabled_int
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/reset_tx_int
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/read_ifg_int
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/apply_pause_delay
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/store_pause_frame
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TXD_PAUSE_DEL0
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TXD_PAUSE_DEL1
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TXD_PAUSE_DEL2
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TXC_PAUSE_DEL0
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TXC_PAUSE_DEL1
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TXC_PAUSE_DEL2
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/PAUSEVAL_DEL
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/PAUSEVAL_DEL1
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/PAUSEVAL_DEL2
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/RESET_ERR_PAUSE
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/set_pause_stats
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/store_transmit_pause_value
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/pause_frame_counter
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/shift_pause_data
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/shift_pause_valid
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/shift_pause_valid_del
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {480 ns} 0}
WaveRestoreZoom {225 ns} {617 ns}
configure wave -namecolwidth 403
configure wave -valuecolwidth 182
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
