onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider input
add wave -noupdate -format Logic /rtc_timer_tb/rst
add wave -noupdate -format Logic /rtc_timer_tb/clk
add wave -noupdate -divider {direct write}
add wave -noupdate -format Logic /rtc_timer_tb/time_ld
add wave -noupdate -format Literal /rtc_timer_tb/DUT/time_reg_ns_in
add wave -noupdate -format Literal /rtc_timer_tb/DUT/time_reg_sec_in
add wave -noupdate -divider {freq adjustment}
add wave -noupdate -format Logic /rtc_timer_tb/period_ld
add wave -noupdate -format Literal /rtc_timer_tb/period_in
add wave -noupdate -divider {1s modulo}
add wave -noupdate -divider {time adjustment}
add wave -noupdate -format Logic /rtc_timer_tb/adj_ld
add wave -noupdate -format Literal /rtc_timer_tb/adj_ld_data
add wave -noupdate -format Literal /rtc_timer_tb/DUT/period_adj
add wave -noupdate -divider output
add wave -noupdate -format Literal /rtc_timer_tb/time_reg_sec
add wave -noupdate -format Literal /rtc_timer_tb/time_reg_ns
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {INTERNAL Signals}
add wave -noupdate -divider {precise time control}
add wave -noupdate -format Literal -radix hexadecimal /rtc_timer_tb/DUT/adj_cnt
add wave -noupdate -format Logic /rtc_timer_tb/DUT/adj_ld_done
add wave -noupdate -format Literal -radix hexadecimal /rtc_timer_tb/DUT/time_adj
add wave -noupdate -divider Delta-Sigma
add wave -noupdate -format Literal /rtc_timer_tb/DUT/time_adj_08n_32f
add wave -noupdate -format Literal /rtc_timer_tb/DUT/time_adj_16b_00n_24f
add wave -noupdate -format Literal /rtc_timer_tb/DUT/time_adj_22b_08n_08f
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /rtc_timer_tb/DUT/time_acc_30n_08f_pre_pos
add wave -noupdate -format Literal /rtc_timer_tb/DUT/time_acc_30n_08f_pre_neg
add wave -noupdate -format Literal /rtc_timer_tb/DUT/time_acc_modulo
add wave -noupdate -format Logic /rtc_timer_tb/DUT/time_acc_48s_inc
add wave -noupdate -format Literal /rtc_timer_tb/DUT/time_acc_48s
add wave -noupdate -format Literal /rtc_timer_tb/DUT/time_acc_30n_08f
add wave -noupdate -divider {WATCHPOINT Signals}
add wave -noupdate -divider {ns and sec}
add wave -noupdate -format Literal -radix unsigned /rtc_timer_tb/time_reg_sec__delta
add wave -noupdate -format Literal -radix unsigned /rtc_timer_tb/time_reg_ns__delta
add wave -noupdate -format Literal /rtc_timer_tb/time_acc_30n_08f_pre
add wave -noupdate -format Literal -radix unsigned /rtc_timer_tb/time_reg_sec_in_
add wave -noupdate -format Literal -radix unsigned /rtc_timer_tb/time_reg_ns_in_
add wave -noupdate -format Literal -radix unsigned /rtc_timer_tb/time_reg_sec_
add wave -noupdate -format Logic /rtc_timer_tb/time_reg_sec_inc_
add wave -noupdate -format Literal -radix unsigned /rtc_timer_tb/time_reg_ns_
add wave -noupdate -format Literal -radix unsigned /rtc_timer_tb/period_ns_
add wave -noupdate -format Literal -radix unsigned /rtc_timer_tb/period_adj_ns_
add wave -noupdate -divider {ns fraction}
add wave -noupdate -format Literal /rtc_timer_tb/time_reg_ns_in_f
add wave -noupdate -format Literal /rtc_timer_tb/time_reg_ns_f
add wave -noupdate -format Literal /rtc_timer_tb/period_ns_f
add wave -noupdate -format Literal /rtc_timer_tb/period_adj_ns_f
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {620 ns} 0}
configure wave -namecolwidth 222
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
WaveRestoreZoom {0 ns} {13007 ns}
