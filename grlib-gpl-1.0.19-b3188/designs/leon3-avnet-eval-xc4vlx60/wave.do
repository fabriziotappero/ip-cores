onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/clk50
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Literal -radix hexadecimal /testbench/address
add wave -noupdate -format Literal -radix hexadecimal /testbench/data
add wave -noupdate -format Literal /testbench/romsn
add wave -noupdate -format Logic /testbench/oen
add wave -noupdate -format Logic /testbench/writen
add wave -noupdate -format Logic /testbench/ddr_clk
add wave -noupdate -format Logic /testbench/ddr_clkb
add wave -noupdate -format Logic /testbench/ddr_cke
add wave -noupdate -format Logic /testbench/ddr_clk_fb
add wave -noupdate -format Logic /testbench/d3/clkm
add wave -noupdate -format Logic /testbench/ddr_csb
add wave -noupdate -format Logic /testbench/ddr_web
add wave -noupdate -format Logic /testbench/ddr_rasb
add wave -noupdate -format Logic /testbench/ddr_casb
add wave -noupdate -format Literal /testbench/ddr_dm
add wave -noupdate -format Literal /testbench/ddr_dqs
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_ad
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_ba
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_dq
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/sdi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/sdo
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbso
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbmi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbmo
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/apbi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/apbo
add wave -noupdate -format Logic /testbench/d3/ddrsp0/ddrc/clk_ddr
add wave -noupdate -format Logic /testbench/d3/ddrsp0/ddrc/clk_ahb
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ddrsp0/ddrc/ddr16/ddrc/r
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ddrsp0/ddrc/ddr16/ddrc/ra
add wave -noupdate -format Logic /testbench/d3/clkml
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {38711250 ps} 0} {{Cursor 2} {1272390 ps} 0}
configure wave -namecolwidth 142
configure wave -valuecolwidth 77
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
WaveRestoreZoom {441787656 ps} {2154584480 ps}
