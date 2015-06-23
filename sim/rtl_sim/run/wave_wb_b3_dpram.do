onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {A side}
add wave -noupdate -format Literal -radix hexadecimal /vl_wb_b3_dpram_tb/wbm_a_dat_o
add wave -noupdate -format Literal /vl_wb_b3_dpram_tb/wbm_a_sel_o
add wave -noupdate -format Literal -radix hexadecimal /vl_wb_b3_dpram_tb/wbm_a_adr_o
add wave -noupdate -format Literal /vl_wb_b3_dpram_tb/wbm_a_cti_o
add wave -noupdate -format Literal /vl_wb_b3_dpram_tb/wbm_a_bte_o
add wave -noupdate -format Logic /vl_wb_b3_dpram_tb/wbm_a_we_o
add wave -noupdate -format Logic /vl_wb_b3_dpram_tb/wbm_a_cyc_o
add wave -noupdate -format Logic /vl_wb_b3_dpram_tb/wbm_a_stb_o
add wave -noupdate -format Literal -radix hexadecimal /vl_wb_b3_dpram_tb/wbm_a_dat_i
add wave -noupdate -format Logic /vl_wb_b3_dpram_tb/wbm_a_ack_i
add wave -noupdate -format Logic /vl_wb_b3_dpram_tb/wbm_a_clk
add wave -noupdate -format Logic /vl_wb_b3_dpram_tb/wbm_a_rst
add wave -noupdate -divider {B side}
add wave -noupdate -format Literal -radix hexadecimal /vl_wb_b3_dpram_tb/wbm_b_dat_o
add wave -noupdate -format Literal /vl_wb_b3_dpram_tb/wbm_b_sel_o
add wave -noupdate -format Literal -radix hexadecimal /vl_wb_b3_dpram_tb/wbm_b_adr_o
add wave -noupdate -format Literal /vl_wb_b3_dpram_tb/wbm_b_cti_o
add wave -noupdate -format Literal /vl_wb_b3_dpram_tb/wbm_b_bte_o
add wave -noupdate -format Logic /vl_wb_b3_dpram_tb/wbm_b_we_o
add wave -noupdate -format Logic /vl_wb_b3_dpram_tb/wbm_b_cyc_o
add wave -noupdate -format Logic /vl_wb_b3_dpram_tb/wbm_b_stb_o
add wave -noupdate -format Literal -radix hexadecimal /vl_wb_b3_dpram_tb/wbm_b_dat_i
add wave -noupdate -format Logic /vl_wb_b3_dpram_tb/wbm_b_ack_i
add wave -noupdate -format Logic /vl_wb_b3_dpram_tb/wbm_b_clk
add wave -noupdate -format Logic /vl_wb_b3_dpram_tb/wbm_b_rst
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {131 ns} 0}
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
WaveRestoreZoom {0 ns} {1 us}
