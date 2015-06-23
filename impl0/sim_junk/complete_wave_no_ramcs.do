onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {CPU interfacing}
add wave -noupdate -format Logic -label CLK_I /test/clk_i
add wave -noupdate -format Logic -label RST_I /test/rst_i
add wave -noupdate -format Logic -label ACK_I /test/ack_i
add wave -noupdate -format Logic -label INTR_I /test/intr_i
add wave -noupdate -format Literal -label SEL_O /test/sel_o
add wave -noupdate -format Logic -label STB_O /test/stb_o
add wave -noupdate -format Logic -label CYC_O /test/cyc_o
add wave -noupdate -format Logic -label WE_O /test/we_o
add wave -noupdate -format Logic -label INTA_CYC_O /test/inta_cyc_o
add wave -noupdate -format Logic -label I_CYC_O /test/i_cyc_o
add wave -noupdate -format Logic -label C_CYC_O /test/c_cyc_o
add wave -noupdate -format Logic -label D_CYC_O /test/d_cyc_o
add wave -noupdate -format Literal -label ADR_O -radix hexadecimal /test/adr_o
add wave -noupdate -format Literal -label DAT_IO -radix hexadecimal /test/dat_io
add wave -noupdate -divider {CPU internal (DP)}
add wave -noupdate -format Literal -label GPRs -radix hexadecimal -expand /test/cpu/datapath/u1/regfile_data
add wave -noupdate -format Literal -label IR -radix hexadecimal /test/cpu/datapath/ir_out
add wave -noupdate -format Literal -label MDRI -radix hexadecimal /test/cpu/datapath/mdri_out
add wave -noupdate -format Literal -label TR2 -radix hexadecimal /test/cpu/datapath/tr2_out
add wave -noupdate -format Literal -label PC -radix hexadecimal /test/cpu/datapath/pc_out
add wave -noupdate -format Literal -label SP -radix hexadecimal /test/cpu/datapath/sp_out
add wave -noupdate -format Literal -label FLAGS /test/cpu/datapath/flags_out
add wave -noupdate -format Literal -label INTR /test/cpu/datapath/intr_out
add wave -noupdate -format Literal -label MAR -radix hexadecimal /test/cpu/datapath/mar_out
add wave -noupdate -format Literal -label DFH -radix hexadecimal /test/cpu/datapath/dfh_out
add wave -noupdate -format Literal -label MDRO -radix hexadecimal /test/cpu/datapath/mdro_out
add wave -noupdate -divider {CPU Internal (Con)}
add wave -noupdate -format Logic -label Jcc_OK /test/cpu/control/jcc_ok
add wave -noupdate -format Logic -label rst_sync /test/cpu/control/rst_sync
add wave -noupdate -format Logic -label ack_sync /test/cpu/control/ack_sync
add wave -noupdate -format Logic -label intr_sync /test/cpu/control/intr_sync
add wave -noupdate -format Literal -label cur_state /test/cpu/control/cur_state
add wave -noupdate -format Literal -label nxt_state /test/cpu/control/nxt_state
add wave -noupdate -format Literal -label cur_ic /test/cpu/control/cur_ic
add wave -noupdate -divider RAM
add wave -noupdate -format Literal -label RAM_data_upper -radix hexadecimal /test/ram/line__87/ram_data_upper
add wave -noupdate -format Literal -label RAM_data_lower -radix hexadecimal /test/ram/line__87/ram_data_lower
add wave -noupdate -divider RAM2
add wave -noupdate -format Literal -label RAM2_data_upper -radix hexadecimal /test/ram2/write_low/ram_data_upper
add wave -noupdate -format Literal -label RAM2_data_lower -radix hexadecimal /test/ram2/write_low/ram_data_lower
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {200000 ps} 0}
WaveRestoreZoom {0 ps} {197600 ps}
configure wave -namecolwidth 139
configure wave -valuecolwidth 95
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
