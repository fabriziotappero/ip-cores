onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /lq057q3dc02_tb/rstx
add wave -noupdate -format Logic /lq057q3dc02_tb/clk_lcd
add wave -noupdate -divider -height 30 VSYNCx_Controller
add wave -noupdate -format Literal /lq057q3dc02_tb/uut/v_c/vsyncx_c/line_cntr_cs
add wave -noupdate -format Literal -radix unsigned /lq057q3dc02_tb/uut/v_c/vsyncx_c/line_num
add wave -noupdate -format Logic /lq057q3dc02_tb/vsyncx
add wave -noupdate -divider -height 25 HSYNCx_Controller
add wave -noupdate -format Logic /lq057q3dc02_tb/hsyncx
add wave -noupdate -format Literal -radix unsigned /lq057q3dc02_tb/uut/v_c/hsyncx_c/num_hsyncx_clocks_reg
add wave -noupdate -divider -height 30 ENAB_Controller
add wave -noupdate -format Logic /lq057q3dc02_tb/uut/v_c/enab_c/enab
add wave -noupdate -divider -height 30 CLK_LCD_CYC_Counter
add wave -noupdate -format Literal -radix unsigned /lq057q3dc02_tb/uut/v_c/clk_lcd_cycle_cntr/clk_lcd_cyc_num
add wave -noupdate -format Literal /lq057q3dc02_tb/uut/v_c/clk_lcd_cycle_cntr/clk_cntr_cs
add wave -noupdate -divider -height 30 Image_Gen
add wave -noupdate -format Logic /lq057q3dc02_tb/uut/image/sinit_wire
add wave -noupdate -format Literal -radix unsigned /lq057q3dc02_tb/uut/image/addr_wire
add wave -noupdate -divider -height 30 {COLOR DATA}
add wave -noupdate -format Literal /lq057q3dc02_tb/r
add wave -noupdate -format Literal /lq057q3dc02_tb/g
add wave -noupdate -format Literal /lq057q3dc02_tb/b
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3024646983 ps} 0}
configure wave -namecolwidth 361
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
update
WaveRestoreZoom {887271898 ps} {887629557 ps}
