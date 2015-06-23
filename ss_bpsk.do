onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix unsigned /tb_spread_bpsk_0/v_count
add wave -noupdate -format Literal /tb_spread_bpsk_0/v_count
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/clk_i
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/reset_i
add wave -noupdate -format Literal -radix unsigned /tb_spread_bpsk_0/uut/data_i
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/fifo_ce
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/data_valid_i
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/triger_type_i
add wave -noupdate -format Literal /tb_spread_bpsk_0/uut/spread_sequence_i
add wave -noupdate -color {Orange Red} -format Logic /tb_spread_bpsk_0/uut/data_valid_o
add wave -noupdate -color Gold -format Logic /tb_spread_bpsk_0/uut/data_procesing
add wave -noupdate -format Literal -radix unsigned -expand /tb_spread_bpsk_0/uut/v_fifo_data_spread
add wave -noupdate -format Literal -radix unsigned /tb_spread_bpsk_0/uut/v_spread_count
add wave -noupdate -format Literal /tb_spread_bpsk_0/uut/data_o
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/ready_for_data_o
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/fifo_read
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/fifo_empty
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/rfd
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/spread_triger
add wave -noupdate -format Literal -radix unsigned /tb_spread_bpsk_0/uut/v_fifo_data
add wave -noupdate -format Literal -radix hexadecimal /tb_spread_bpsk_0/uut/v_delay_counter
add wave -noupdate -format Literal /tb_spread_bpsk_0/uut/i_delay_counter
add wave -noupdate -format Literal -radix unsigned /tb_spread_bpsk_0/uut/v_data_in
add wave -noupdate -format Literal /tb_spread_bpsk_0/uut/g0__3/fifo_in/shift_reg
add wave -noupdate -color Gold -format Literal /tb_spread_bpsk_0/uut/g0__2/fifo_in/shift_reg
add wave -noupdate -format Literal /tb_spread_bpsk_0/uut/g0__1/fifo_in/shift_reg
add wave -noupdate -color Gold -format Literal /tb_spread_bpsk_0/uut/g0__0/fifo_in/shift_reg
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/g0__3/fifo_in/q15
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/g0__2/fifo_in/q15
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/g0__1/fifo_in/q15
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/g0__0/fifo_in/q15
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/g0__3/fifo_in/q
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/g0__2/fifo_in/q
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/g0__1/fifo_in/q
add wave -noupdate -format Logic /tb_spread_bpsk_0/uut/g0__0/fifo_in/q
add wave -noupdate -color Firebrick -format Logic /tb_spread_bpsk_0/uut/fifo_read
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1430829 ps} 0}
configure wave -namecolwidth 355
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
configure wave -timeline 1
update
WaveRestoreZoom {0 ps} {4200 ns}
