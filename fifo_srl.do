onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/v_count
add wave -noupdate -format Literal /tb_fifo_srl_uni_1/i_count_write
add wave -noupdate -format Literal /tb_fifo_srl_uni_1/i_count_read
add wave -noupdate -format Logic -radix decimal /tb_fifo_srl_uni_1/uut/clk_i
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/uut/data_i
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/uut/data_o
add wave -noupdate -format Logic -radix decimal /tb_fifo_srl_uni_1/uut/write_enable_i
add wave -noupdate -format Logic -radix decimal /tb_fifo_srl_uni_1/uut/read_enable_i
add wave -noupdate -format Logic -radix decimal /tb_fifo_srl_uni_1/uut/read_valid_o
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/uut/fifo_count_o
add wave -noupdate -format Logic -radix decimal /tb_fifo_srl_uni_1/uut/full_flag_o
add wave -noupdate -format Logic -radix decimal /tb_fifo_srl_uni_1/uut/empty_flag_o
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/uut/v_delay_counter
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/uut/v_size_counter
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/uut/v_zeros
add wave -noupdate -format Literal /tb_fifo_srl_uni_1/uut/v_write_enable
add wave -noupdate -format Literal /tb_fifo_srl_uni_1/uut/v_read_enable
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/uut/i_size_counter
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/uut/i_srl_select
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/uut/i_temp
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/uut/t_mux_in
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/uut/t_srl_in
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/uut/t_mux_out
add wave -noupdate -format Literal -radix decimal /tb_fifo_srl_uni_1/uut/t_reg_in
add wave -noupdate -format Logic -radix decimal /tb_fifo_srl_uni_1/uut/one_delay
add wave -noupdate -format Logic -radix decimal /tb_fifo_srl_uni_1/uut/ce_master
add wave -noupdate -format Logic -radix decimal /tb_fifo_srl_uni_1/uut/full_capacity
add wave -noupdate -format Logic -radix decimal /tb_fifo_srl_uni_1/uut/data_valid_off
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {164834 ps} 0}
configure wave -namecolwidth 259
configure wave -valuecolwidth 67
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
WaveRestoreZoom {0 ps} {840 ns}
