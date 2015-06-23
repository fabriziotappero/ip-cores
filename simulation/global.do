onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Global Signals}
add wave -noupdate -format Logic /tb_rise_vhd/reset
add wave -noupdate -format Logic /tb_rise_vhd/clk
add wave -noupdate -divider {Instruction Fetch Unit}
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/if_stage_unit/pc
add wave -noupdate -format Logic /tb_rise_vhd/uut/if_stage_unit/clear_in
add wave -noupdate -format Logic /tb_rise_vhd/uut/if_stage_unit/stall_in
add wave -noupdate -format Literal -expand /tb_rise_vhd/uut/if_stage_unit/if_id_register
add wave -noupdate -divider {Instruction Decode Unit}
add wave -noupdate -format Logic /tb_rise_vhd/uut/id_stage_unit/clear_in
add wave -noupdate -format Logic /tb_rise_vhd/uut/id_stage_unit/stall_in
add wave -noupdate -format Logic /tb_rise_vhd/uut/id_stage_unit/stall_out
add wave -noupdate -format Literal -expand /tb_rise_vhd/uut/id_stage_unit/id_ex_register
add wave -noupdate -divider {Execute Unit}
add wave -noupdate -format Literal -expand /tb_rise_vhd/uut/mem_stage_unit/ex_mem_register
add wave -noupdate -divider {Memory Unit}
add wave -noupdate -format Logic /tb_rise_vhd/uut/mem_stage_unit/dmem_wr_enable
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/mem_stage_unit/dmem_data_out
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/mem_stage_unit/dmem_data_in
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/mem_stage_unit/dmem_addr
add wave -noupdate -format Literal -expand /tb_rise_vhd/uut/mem_stage_unit/mem_wb_register
add wave -noupdate -divider {Write Back Unit}
add wave -noupdate -format Logic /tb_rise_vhd/uut/wb_stage_unit/dreg_enable
add wave -noupdate -format Literal -radix decimal /tb_rise_vhd/uut/wb_stage_unit/dreg_addr
add wave -noupdate -format Literal /tb_rise_vhd/uut/wb_stage_unit/dreg
add wave -noupdate -divider Registers
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_0
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_1
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_2
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_3
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_4
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_5
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_6
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_7
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_8
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_9
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_10
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_11
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_12
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_13
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_14
add wave -noupdate -format Literal -radix hexadecimal /tb_rise_vhd/uut/register_file_unit/reg_15
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {83205 ps} 0}
configure wave -namecolwidth 302
configure wave -valuecolwidth 155
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
WaveRestoreZoom {0 ps} {100385 ps}
