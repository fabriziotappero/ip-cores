onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/cpu/resetn
add wave -noupdate -format Logic /testbench/cpu/clk
add wave -noupdate -format Logic /testbench/cpu/errorn
add wave -noupdate -format Literal /testbench/cpu/ddr_clk
add wave -noupdate -format Literal /testbench/cpu/ddr_clkb
add wave -noupdate -format Logic /testbench/cpu/ddr_clk_fb
add wave -noupdate -format Logic /testbench/cpu/ddr_clk_fb_out
add wave -noupdate -format Literal /testbench/cpu/ddr_cke
add wave -noupdate -format Literal /testbench/cpu/ddr_csb
add wave -noupdate -format Logic /testbench/cpu/ddr_web
add wave -noupdate -format Logic /testbench/cpu/ddr_rasb
add wave -noupdate -format Logic /testbench/cpu/ddr_casb
add wave -noupdate -format Literal /testbench/cpu/ddr_dm
add wave -noupdate -format Literal /testbench/cpu/ddr_dqs
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ddr_ad
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ddr_ba
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ddr_dq
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/apbi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/apbo
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbso
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbmi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbmo
add wave -noupdate -format Logic /testbench/cpu/clkm
add wave -noupdate -format Logic /testbench/cpu/rstn
add wave -noupdate -format Logic /testbench/cpu/clkddr
add wave -noupdate -format Logic /testbench/cpu/ddrlock
add wave -noupdate -format Logic /testbench/cpu/lock
add wave -noupdate -format Logic /testbench/cpu/clkml
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ddrsp0/ddr0/ddr64/ddrc/r
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ddrsp0/ddr0/ddr64/ddrc/ra
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/l3/cpu__0/u0/p0/iu0/r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10461406 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 151
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
WaveRestoreZoom {10407448 ps} {10535762 ps}
