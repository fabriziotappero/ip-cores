onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_pid_controler_0/clk_i
add wave -noupdate -format Logic /tb_pid_controler_0/reset_i
add wave -noupdate -format Literal /tb_pid_controler_0/error_i
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/patern_i
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/patern_estimation_i
add wave -noupdate -format Analog-Step -height 170 -offset 10.0 -radix decimal /tb_pid_controler_0/correct_o
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/correct_o
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/v_count
add wave -noupdate -format Logic -radix decimal /tb_pid_controler_0/uut/clk_i
add wave -noupdate -format Logic -radix decimal /tb_pid_controler_0/uut/reset_i
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/uut/error_i
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/uut/patern_i
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/uut/patern_estimation_i
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/uut/correct_o
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/uut/v_error
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/uut/v_error_km
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/uut/v_error_kp
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/uut/v_error_kd
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/uut/v_error_ki
add wave -noupdate -format Literal -radix decimal -expand /tb_pid_controler_0/uut/t_div_late
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/uut/v_div
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/uut/v_acu_earl
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/uut/v_acu
add wave -noupdate -format Literal -radix decimal /tb_pid_controler_0/uut/v_sum
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {798697 ps} 0}
configure wave -namecolwidth 284
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
WaveRestoreZoom {0 ps} {3150 ns}
