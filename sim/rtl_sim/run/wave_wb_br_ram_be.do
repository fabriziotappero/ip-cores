onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Wishbone
add wave -noupdate -format Literal -radix hexadecimal /vl_wb_b3_ram_be_tb/wbm_a_dat_o
add wave -noupdate -format Literal /vl_wb_b3_ram_be_tb/wbm_a_sel_o
add wave -noupdate -format Literal -radix hexadecimal /vl_wb_b3_ram_be_tb/wbm_a_adr_o
add wave -noupdate -format Literal /vl_wb_b3_ram_be_tb/wbm_a_cti_o
add wave -noupdate -format Literal /vl_wb_b3_ram_be_tb/wbm_a_bte_o
add wave -noupdate -format Logic /vl_wb_b3_ram_be_tb/wbm_a_we_o
add wave -noupdate -format Logic /vl_wb_b3_ram_be_tb/wbm_a_cyc_o
add wave -noupdate -format Logic /vl_wb_b3_ram_be_tb/wbm_a_stb_o
add wave -noupdate -format Literal -radix hexadecimal /vl_wb_b3_ram_be_tb/wbm_a_dat_i
add wave -noupdate -format Logic /vl_wb_b3_ram_be_tb/wbm_a_ack_i
add wave -noupdate -divider Memory
add wave -noupdate -format Literal -radix hexadecimal /vl_wb_b3_ram_be_tb/dut/ram0/d
add wave -noupdate -format Literal -radix hexadecimal /vl_wb_b3_ram_be_tb/dut/ram0/adr
add wave -noupdate -format Literal /vl_wb_b3_ram_be_tb/dut/ram0/be
add wave -noupdate -format Logic /vl_wb_b3_ram_be_tb/dut/ram0/we
add wave -noupdate -format Literal -radix hexadecimal /vl_wb_b3_ram_be_tb/dut/ram0/q
add wave -noupdate -format Literal /vl_wb_b3_ram_be_tb/dut/adr_inc0/last_adr
add wave -noupdate -format Literal /vl_wb_b3_ram_be_tb/dut/adr_inc0/last_cycle
add wave -noupdate -divider {Clock and reset}
add wave -noupdate -format Logic /vl_wb_b3_ram_be_tb/wbm_a_clk
add wave -noupdate -format Logic /vl_wb_b3_ram_be_tb/wbm_a_rst
add wave -noupdate -format Literal /vl_wb_b3_ram_be_tb/wbmi/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {654 ns} 0} {{Cursor 2} {1030 ns} 0}
configure wave -namecolwidth 150
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
WaveRestoreZoom {817 ns} {1104 ns}
