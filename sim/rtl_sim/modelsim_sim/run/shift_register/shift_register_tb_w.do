onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /shift_register_tb/test_num
add wave -noupdate -format Logic /shift_register_tb/s_rst
add wave -noupdate -divider External
add wave -noupdate -format Logic /shift_register_tb/s_sclk
add wave -noupdate -format Logic /shift_register_tb/s_cs_n
add wave -noupdate -format Logic /shift_register_tb/s_mosi
add wave -noupdate -format Logic /shift_register_tb/s_miso_o
add wave -noupdate -format Logic /shift_register_tb/s_miso_i
add wave -noupdate -format Logic /shift_register_tb/s_miso_t
add wave -noupdate -divider TX-FIFO
add wave -noupdate -format Logic /shift_register_tb/s_tx_clk
add wave -noupdate -format Logic /shift_register_tb/s_tx_en
add wave -noupdate -format Literal -radix unsigned /shift_register_tb/s_tx_data
add wave -noupdate -divider RX-FIFO
add wave -noupdate -format Logic /shift_register_tb/s_rx_clk
add wave -noupdate -format Logic /shift_register_tb/s_rx_en
add wave -noupdate -format Literal /shift_register_tb/s_rx_data
add wave -noupdate -divider Internal
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {62874 ps} 0}
configure wave -namecolwidth 281
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
update
WaveRestoreZoom {0 ps} {3570 ns}
