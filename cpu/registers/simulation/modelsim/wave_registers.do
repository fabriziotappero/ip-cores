onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_registers/clk
add wave -noupdate -expand -group {Address Side} -itemcolor Black -radix hexadecimal -childformat {{{/test_registers/db_lo_as[7]} -radix hexadecimal} {{/test_registers/db_lo_as[6]} -radix hexadecimal} {{/test_registers/db_lo_as[5]} -radix hexadecimal} {{/test_registers/db_lo_as[4]} -radix hexadecimal} {{/test_registers/db_lo_as[3]} -radix hexadecimal} {{/test_registers/db_lo_as[2]} -radix hexadecimal} {{/test_registers/db_lo_as[1]} -radix hexadecimal} {{/test_registers/db_lo_as[0]} -radix hexadecimal}} -subitemconfig {{/test_registers/db_lo_as[7]} {-height 15 -itemcolor Black -radix hexadecimal} {/test_registers/db_lo_as[6]} {-height 15 -itemcolor Black -radix hexadecimal} {/test_registers/db_lo_as[5]} {-height 15 -itemcolor Black -radix hexadecimal} {/test_registers/db_lo_as[4]} {-height 15 -itemcolor Black -radix hexadecimal} {/test_registers/db_lo_as[3]} {-height 15 -itemcolor Black -radix hexadecimal} {/test_registers/db_lo_as[2]} {-height 15 -itemcolor Black -radix hexadecimal} {/test_registers/db_lo_as[1]} {-height 15 -itemcolor Black -radix hexadecimal} {/test_registers/db_lo_as[0]} {-height 15 -itemcolor Black -radix hexadecimal}} /test_registers/db_lo_as
add wave -noupdate -expand -group {Address Side} -itemcolor Black -radix hexadecimal /test_registers/db_lo_as_sig
add wave -noupdate -expand -group {Address Side} -itemcolor Black -radix hexadecimal /test_registers/db_hi_as
add wave -noupdate -expand -group {Address Side} -itemcolor Black -radix hexadecimal /test_registers/db_hi_as_sig
add wave -noupdate -expand -group {Data Side} -itemcolor Black -radix hexadecimal /test_registers/db_lo_ds
add wave -noupdate -expand -group {Data Side} -itemcolor Black -radix hexadecimal /test_registers/db_lo_ds_sig
add wave -noupdate -expand -group {Data Side} -itemcolor Black -radix hexadecimal /test_registers/db_hi_ds
add wave -noupdate -expand -group {Data Side} -itemcolor Black -radix hexadecimal /test_registers/db_hi_ds_sig
add wave -noupdate -divider Control
add wave -noupdate -itemcolor Violet /test_registers/ctl_sw_4u_sig
add wave -noupdate -itemcolor Violet /test_registers/ctl_sw_4d_sig
add wave -noupdate /test_registers/ctl_reg_in_hi_sig
add wave -noupdate /test_registers/ctl_reg_in_lo_sig
add wave -noupdate /test_registers/ctl_reg_out_hi_sig
add wave -noupdate /test_registers/ctl_reg_out_lo_sig
add wave -noupdate /test_registers/ctl_reg_exx_sig
add wave -noupdate /test_registers/ctl_reg_ex_af_sig
add wave -noupdate /test_registers/ctl_reg_ex_de_hl_sig
add wave -noupdate /test_registers/ctl_reg_use_sp_sig
add wave -noupdate /test_registers/ctl_reg_sel_wz_sig
add wave -noupdate /test_registers/ctl_reg_sel_pc_sig
add wave -noupdate /test_registers/ctl_reg_sel_ir_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_bc_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_bc2_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_de_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_de2_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_hl_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_hl2_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_af_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_af2_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_ix_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_iy_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_wz_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_pc_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_ir_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_gp_hi_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_gp_lo_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_sys_hi_sig
add wave -noupdate -color Coral -itemcolor Gold /test_registers/reg_sel_sys_lo_sig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1300 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 236
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
configure wave -timeline 1
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ns} {7800 ns}
