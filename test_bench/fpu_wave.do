onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_fpu/clk_i
add wave -noupdate -format Literal /tb_fpu/opa_i
add wave -noupdate -format Literal /tb_fpu/opb_i
add wave -noupdate -format Literal /tb_fpu/fpu_op_i
add wave -noupdate -format Literal /tb_fpu/rmode_i
add wave -noupdate -format Literal /tb_fpu/output_o
add wave -noupdate -format Logic /tb_fpu/start_i
add wave -noupdate -format Logic /tb_fpu/ready_o
add wave -noupdate -format Logic /tb_fpu/ine_o
add wave -noupdate -format Logic /tb_fpu/overflow_o
add wave -noupdate -format Logic /tb_fpu/underflow_o
add wave -noupdate -format Logic /tb_fpu/div_zero_o
add wave -noupdate -format Logic /tb_fpu/inf_o
add wave -noupdate -format Logic /tb_fpu/zero_o
add wave -noupdate -format Logic /tb_fpu/qnan_o
add wave -noupdate -format Logic /tb_fpu/snan_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {16182 ns} 0}
configure wave -namecolwidth 255
configure wave -valuecolwidth 317
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
WaveRestoreZoom {0 ns} {544 ns}
