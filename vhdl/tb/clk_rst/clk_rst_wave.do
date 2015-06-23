onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /clk_rst_tb/tb_clk
add wave -noupdate -format Logic /clk_rst_tb/tb_rst
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /clk_rst_tb/uut/clk
add wave -noupdate -format Logic /clk_rst_tb/uut/rst
add wave -noupdate -format Logic /clk_rst_tb/uut/iclk
add wave -noupdate -format Logic /clk_rst_tb/uut/irst
add wave -noupdate -format Logic /clk_rst_tb/uut/verbose
add wave -noupdate -format Literal /clk_rst_tb/uut/clock_frequency
add wave -noupdate -format Literal /clk_rst_tb/uut/min_resetwidth
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {155200 ps} 0}
configure wave -namecolwidth 271
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
WaveRestoreZoom {0 ps} {195904 ps}
