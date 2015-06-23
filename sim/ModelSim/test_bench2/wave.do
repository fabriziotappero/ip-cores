onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {WishBone signals}
add wave -noupdate -format Logic -label wb_rst_i -radix binary /test_miniuart/dut/wb_rst_i
add wave -noupdate -format Logic -label wb_clk_i -radix binary /test_miniuart/dut/wb_clk_i
add wave -noupdate -format Logic -label wb_stb_i -radix binary /test_miniuart/dut/wb_stb_i
add wave -noupdate -format Logic -label wb_ack_o -radix binary /test_miniuart/dut/wb_ack_o
add wave -noupdate -format Logic -label wb_we_i -radix binary /test_miniuart/dut/wb_we_i
add wave -noupdate -format Literal -label wb_adr_i -radix hexadecimal /test_miniuart/dut/wb_adr_i
add wave -noupdate -format Literal -label wb_dat_i -radix hexadecimal /test_miniuart/dut/wb_dat_i
add wave -noupdate -format Literal -label wb_dat_o -radix hexadecimal /test_miniuart/dut/wb_dat_o
add wave -noupdate -divider {UART signals}
add wave -noupdate -format Logic -label br_clk_i -radix binary /test_miniuart/dut/br_clk_i
add wave -noupdate -format Logic -label txd_pad_o -radix binary /test_miniuart/dut/txd_pad_o
add wave -noupdate -format Logic -label inttx_o -radix binary /test_miniuart/dut/inttx_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {141951 ns}
WaveRestoreZoom {96671 ns} {342281 ns}
configure wave -namecolwidth 110
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
