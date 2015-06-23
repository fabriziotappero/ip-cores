onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_CONTROL/rstn
add wave -noupdate -format Logic /tb_CONTROL/clk
add wave -noupdate -color White -format Logic /tb_CONTROL/i_mk_rdy
add wave -noupdate -color White -format Logic /tb_CONTROL/i_text_val
add wave -noupdate -color White -format Logic /tb_CONTROL/o_rdy
add wave -noupdate -color White -format Logic /tb_CONTROL/i_post_rdy
add wave -noupdate -color White -format Logic /tb_CONTROL/o_text_done
add wave -noupdate -color Yellow -format Logic /tb_CONTROL/o_rf_final
add wave -noupdate -color Yellow -format Logic /tb_CONTROL/o_key_sel
add wave -noupdate -color Yellow -format Logic /tb_CONTROL/o_wf_post_pre
add wave -noupdate -format Literal -radix unsigned /tb_CONTROL/o_rnd_idx
add wave -noupdate -format Literal /tb_CONTROL/o_xf_sel
add wave -noupdate -color {Medium Violet Red} -format Literal -radix ascii /tb_CONTROL/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {87818 ps} 0} {{Cursor 2} {849919 ps} 0}
configure wave -namecolwidth 211
configure wave -valuecolwidth 62
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
WaveRestoreZoom {0 ps} {1004659 ps}
