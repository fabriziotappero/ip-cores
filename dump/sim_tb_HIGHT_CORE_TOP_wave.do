onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_HIGHT_CORE_TOP/rstn
add wave -noupdate /tb_HIGHT_CORE_TOP/clk
add wave -noupdate -color Coral /tb_HIGHT_CORE_TOP/i_op
add wave -noupdate -radix hexadecimal /tb_HIGHT_CORE_TOP/i_mk
add wave -noupdate -color White /tb_HIGHT_CORE_TOP/i_mk_rdy
add wave -noupdate -color White /tb_HIGHT_CORE_TOP/i_post_rdy
add wave -noupdate -color White -radix binary /tb_HIGHT_CORE_TOP/o_rdy
add wave -noupdate -color Yellow /tb_HIGHT_CORE_TOP/i_text_val
add wave -noupdate -radix hexadecimal /tb_HIGHT_CORE_TOP/i_text_in
add wave -noupdate -radix hexadecimal /tb_HIGHT_CORE_TOP/o_text_out
add wave -noupdate -color Yellow -radix hexadecimal /tb_HIGHT_CORE_TOP/o_text_done
add wave -noupdate -color {Medium Violet Red} -radix ascii /tb_HIGHT_CORE_TOP/state
add wave -noupdate -divider CRYPTO_PATH
add wave -noupdate /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CRYPTO_PATH/rstn
add wave -noupdate /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CRYPTO_PATH/clk
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CRYPTO_PATH/i_op
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CRYPTO_PATH/i_rf_final
add wave -noupdate -radix hexadecimal /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CRYPTO_PATH/r_xf
add wave -noupdate /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CRYPTO_PATH/i_xf_sel
add wave -noupdate -radix hexadecimal /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CRYPTO_PATH/i_text_in
add wave -noupdate -radix hexadecimal /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CRYPTO_PATH/i_wrsk
add wave -noupdate -radix hexadecimal /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CRYPTO_PATH/o_text_out
add wave -noupdate -divider KEY_SCHED
add wave -noupdate /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_KEY_SCHED/rstn
add wave -noupdate /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_KEY_SCHED/clk
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_KEY_SCHED/i_op
add wave -noupdate /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_KEY_SCHED/i_mk
add wave -noupdate /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_KEY_SCHED/i_rnd_idx
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_KEY_SCHED/i_key_sel
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_KEY_SCHED/i_wf_post_pre
add wave -noupdate -radix hexadecimal /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_KEY_SCHED/o_rnd_key
add wave -noupdate -divider CONTROL
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CONTROL/rstn
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CONTROL/clk
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CONTROL/i_mk_rdy
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CONTROL/i_post_rdy
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CONTROL/i_text_val
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CONTROL/o_rdy
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CONTROL/o_text_done
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CONTROL/o_rf_final
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CONTROL/o_wf_post_pre
add wave -noupdate -radix binary /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CONTROL/o_key_sel
add wave -noupdate -radix unsigned /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CONTROL/o_rnd_idx
add wave -noupdate /tb_HIGHT_CORE_TOP/uut_HIGHT_CORE_TOP/u_CONTROL/o_xf_sel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1478519 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 450
configure wave -valuecolwidth 214
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
WaveRestoreZoom {0 ps} {1958250 ps}
