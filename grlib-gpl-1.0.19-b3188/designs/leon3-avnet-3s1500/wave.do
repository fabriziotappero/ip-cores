onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/flash_rst_l
add wave -noupdate -format Logic /testbench/flash_cs_l
add wave -noupdate -format Logic /testbench/sram_oe_l
add wave -noupdate -format Logic /testbench/sram_we_l
add wave -noupdate -format Literal /testbench/sram_cs_l
add wave -noupdate -format Literal /testbench/sram_ben_l
add wave -noupdate -format Literal -radix hexadecimal /testbench/baddr
add wave -noupdate -format Literal -radix hexadecimal /testbench/sram_dq
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/apbi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/apbo
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbso
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbmi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbmo
add wave -noupdate -format Logic /testbench/cpu/tx
add wave -noupdate -format Logic /testbench/cpu/rx
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ua1/uart1/r
add wave -noupdate -format Logic /testbench/sdcsn
add wave -noupdate -format Logic /testbench/sdwen
add wave -noupdate -format Logic /testbench/sdrasn
add wave -noupdate -format Logic /testbench/sdcasn
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/mg2/sr1/sdo
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/mg2/sr1/r
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/mg2/sr1/lsdo
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/mg2/sr1/sdmo
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/mg2/sr1/memo
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/mg2/sr1/sd0/sdctrl/r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {47776875 ps} 0}
configure wave -namecolwidth 178
configure wave -valuecolwidth 115
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
WaveRestoreZoom {47322375 ps} {50996819 ps}
