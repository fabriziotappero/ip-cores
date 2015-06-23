onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/sys_clk
add wave -noupdate -format Logic /testbench/sys_rst_in
add wave -noupdate -format Logic /testbench/errorn
add wave -noupdate -format Literal -radix hexadecimal /testbench/address
add wave -noupdate -format Literal -radix hexadecimal /testbench/data
add wave -noupdate -format Literal /testbench/romsn
add wave -noupdate -format Logic /testbench/iosn
add wave -noupdate -format Logic /testbench/writen
add wave -noupdate -format Logic /testbench/read
add wave -noupdate -format Logic /testbench/oen
add wave -noupdate -format Logic /testbench/flash_rstn
add wave -noupdate -format Logic /testbench/clk125
add wave -noupdate -format Literal /testbench/ddr_clk
add wave -noupdate -format Literal /testbench/ddr_clkb
add wave -noupdate -format Logic /testbench/ddr_clk_fb
add wave -noupdate -format Literal /testbench/ddr_cke
add wave -noupdate -format Literal /testbench/ddr_csb
add wave -noupdate -format Logic /testbench/ddr_web
add wave -noupdate -format Logic /testbench/ddr_rasb
add wave -noupdate -format Logic /testbench/ddr_casb
add wave -noupdate -format Literal /testbench/ddr_dm
add wave -noupdate -format Literal /testbench/ddr_dqs
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_ad
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_ba
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_dq
add wave -noupdate -format Logic /testbench/txd1
add wave -noupdate -format Logic /testbench/rxd1
add wave -noupdate -format Literal /testbench/gpio
add wave -noupdate -divider {CPU 1}
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/apbi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/apbo
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbso
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbmi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbmo
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ddrsp0/ddr0/ddr64/ddrc/r
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ddrsp0/ddr0/ddr64/ddrc/ra
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15761477 ps} 0}
configure wave -namecolwidth 171
configure wave -valuecolwidth 75
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
WaveRestoreZoom {15700807 ps} {15812937 ps}
