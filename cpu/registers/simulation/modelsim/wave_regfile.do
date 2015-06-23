onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_regfile/clk
add wave -noupdate -radix hexadecimal /test_regfile/db_lo_ds
add wave -noupdate -radix hexadecimal /test_regfile/db_lo_ds_sig
add wave -noupdate -radix hexadecimal /test_regfile/db_hi_ds
add wave -noupdate -radix hexadecimal /test_regfile/db_hi_ds_sig
add wave -noupdate /test_regfile/reg_sel_af_sig
add wave -noupdate /test_regfile/reg_sel_af2_sig
add wave -noupdate /test_regfile/reg_sel_bc_sig
add wave -noupdate /test_regfile/reg_sel_bc2_sig
add wave -noupdate /test_regfile/reg_sel_de_sig
add wave -noupdate /test_regfile/reg_sel_de2_sig
add wave -noupdate /test_regfile/reg_sel_hl_sig
add wave -noupdate /test_regfile/reg_sel_hl2_sig
add wave -noupdate /test_regfile/reg_sel_ix_sig
add wave -noupdate /test_regfile/reg_sel_iy_sig
add wave -noupdate /test_regfile/reg_sel_wz_sig
add wave -noupdate /test_regfile/reg_sel_sp_sig
add wave -noupdate /test_regfile/reg_sel_gp_hi_sig
add wave -noupdate /test_regfile/reg_sel_gp_lo_sig
add wave -noupdate /test_regfile/reg_gp_oe_sig
add wave -noupdate /test_regfile/reg_sel_pc_sig
add wave -noupdate /test_regfile/reg_sel_ir_sig
add wave -noupdate /test_regfile/reg_sel_sys_hi_sig
add wave -noupdate /test_regfile/reg_sel_sys_lo_sig
add wave -noupdate /test_regfile/reg_sys_oe_sig
add wave -noupdate -divider Bus
add wave -noupdate -radix hexadecimal /test_regfile/reg_file_inst/db_hi_as
add wave -noupdate -radix hexadecimal /test_regfile/reg_file_inst/db_hi_ds
add wave -noupdate -radix hexadecimal /test_regfile/reg_file_inst/db_lo_as
add wave -noupdate -radix hexadecimal /test_regfile/reg_file_inst/db_lo_ds
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 215
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ns} {10400 ns}
