onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Logic /testbench/errorn
add wave -noupdate -format Literal -radix hexadecimal /testbench/address
add wave -noupdate -format Literal -radix hexadecimal /testbench/data
add wave -noupdate -format Literal /testbench/ramsn
add wave -noupdate -format Logic /testbench/oen
add wave -noupdate -format Logic /testbench/writen
add wave -noupdate -format Logic /testbench/dsuen
add wave -noupdate -format Logic /testbench/dsubre
add wave -noupdate -format Logic /testbench/dsuact
add wave -noupdate -divider {CPU 1}
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/cpu/apbi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/apbo
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/cpu/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbso
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbmi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbmo
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/cpu/test0/r
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/cpu/irqctrl/irqctrl0/r
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/cpu/irqctrl/irqctrl0/irqi
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/cpu/irqctrl/irqctrl0/irqo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {409425576 ps} 0}
configure wave -namecolwidth 162
configure wave -valuecolwidth 110
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
WaveRestoreZoom {356818497 ps} {467316481 ps}
