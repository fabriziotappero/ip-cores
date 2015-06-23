onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /crc_core_tb/rst
add wave -noupdate -format Logic /crc_core_tb/opb_clk
add wave -noupdate -format Logic /crc_core_tb/crc_clr
add wave -noupdate -format Logic /crc_core_tb/opb_m_last_block
add wave -noupdate -divider RX
add wave -noupdate -format Logic /crc_core_tb/fifo_rx_en
add wave -noupdate -format Literal /crc_core_tb/fifo_rx_data
add wave -noupdate -format Literal /crc_core_tb/opb_rx_crc_value
add wave -noupdate -divider TX
add wave -noupdate -format Logic /crc_core_tb/fifo_tx_en
add wave -noupdate -format Literal /crc_core_tb/fifo_tx_data
add wave -noupdate -format Logic /crc_core_tb/tx_crc_insert
add wave -noupdate -format Literal /crc_core_tb/opb_tx_crc_value
add wave -noupdate -divider Internal
add wave -noupdate -format Literal /crc_core_tb/dut/state
add wave -noupdate -format Logic /crc_core_tb/dut/rx_crc_en
add wave -noupdate -format Logic /crc_core_tb/dut/tx_crc_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {493567 ps} 0}
configure wave -namecolwidth 211
configure wave -valuecolwidth 169
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
update
WaveRestoreZoom {0 ps} {582750 ps}
