onerror {resume}
quietly WaveActivateNextPane {} 0
quietly virtual signal -install /light8080_tb0/uut { (context /light8080_tb0/uut )(rbank(14) &rbank(15) )} SP
quietly virtual signal -install /light8080_tb0/uut { (context /light8080_tb0/uut )(rbank(8) &rbank(9) )} PC004
quietly virtual signal -install /light8080_tb0/uut { (context /light8080_tb0/uut )(rbank(0) &rbank(1) )} BC
quietly virtual signal -install /light8080_tb0/uut { (context /light8080_tb0/uut )(rbank(2) &rbank(3) )} DE
quietly virtual signal -install /light8080_tb0/uut { (context /light8080_tb0/uut )(rbank(4) &rbank(5) )} HL
add wave -noupdate -divider {External signals}
add wave -noupdate -format Logic /light8080_tb0/clk
add wave -noupdate -format Logic /light8080_tb0/halt_o
add wave -noupdate -color {Pale Green} -format Literal -radix hexadecimal /light8080_tb0/data_i
add wave -noupdate -color Pink -format Literal -radix hexadecimal /light8080_tb0/data_o
add wave -noupdate -color {Medium Aquamarine} -format Literal -radix hexadecimal /light8080_tb0/addr_o
add wave -noupdate -format Logic /light8080_tb0/vma_o
add wave -noupdate -format Logic /light8080_tb0/rd_o
add wave -noupdate -format Logic /light8080_tb0/wr_o
add wave -noupdate -format Logic /light8080_tb0/fetch_o
add wave -noupdate -divider Registers
add wave -noupdate -color {Medium Slate Blue} -format Literal -label SP -radix hexadecimal /light8080_tb0/uut/SP
add wave -noupdate -color {Indian Red} -format Literal -label PC -radix hexadecimal /light8080_tb0/uut/PC004
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -label PSW -radix binary /light8080_tb0/uut/flag_reg
add wave -noupdate -color {Dark Green} -format Literal -label ACC -radix hexadecimal /light8080_tb0/uut/rbank(7)
add wave -noupdate -color Pink -format Literal -itemcolor Pink -label BC -radix hexadecimal /light8080_tb0/uut/BC
add wave -noupdate -color {Indian Red} -format Literal -itemcolor {Indian Red} -label DE -radix hexadecimal /light8080_tb0/uut/DE
add wave -noupdate -color {Yellow Green} -format Literal -itemcolor {Yellow Green} -label HL -radix hexadecimal /light8080_tb0/uut/HL
add wave -noupdate -divider {Internal signals}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {351700000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 70
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
WaveRestoreZoom {417733549 ps} {419238323 ps}
