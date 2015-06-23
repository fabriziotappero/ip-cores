onerror {resume}
quietly WaveActivateNextPane {} 0
quietly virtual signal -install /light8080_tb/cpu { (context /light8080_tb/cpu )(rbank(14) &rbank(15) )} SP
quietly virtual signal -install /light8080_tb/cpu { (context /light8080_tb/cpu )(rbank(8) &rbank(9) )} PC004
quietly virtual signal -install /light8080_tb/cpu { (context /light8080_tb/cpu )(rbank(0) &rbank(1) )} BC
quietly virtual signal -install /light8080_tb/cpu { (context /light8080_tb/cpu )(rbank(2) &rbank(3) )} DE
quietly virtual signal -install /light8080_tb/cpu { (context /light8080_tb/cpu )(rbank(4) &rbank(5) )} HL
add wave -noupdate -divider External
add wave -noupdate -format Logic /light8080_tb/clk
add wave -noupdate -format Logic /light8080_tb/halt_o
add wave -noupdate -color {Medium Sea Green} -format Logic /light8080_tb/inte_o
add wave -noupdate -color Firebrick -format Logic /light8080_tb/intr_i
add wave -noupdate -color White -format Logic /light8080_tb/inta_o
add wave -noupdate -color {Lime Green} -format Literal -radix hexadecimal /light8080_tb/data_i
add wave -noupdate -color {Cadet Blue} -format Literal -radix hexadecimal /light8080_tb/data_o
add wave -noupdate -format Literal -radix hexadecimal /light8080_tb/addr_o
add wave -noupdate -format Logic /light8080_tb/vma_o
add wave -noupdate -format Logic /light8080_tb/rd_o
add wave -noupdate -format Logic /light8080_tb/wr_o
add wave -noupdate -format Logic /light8080_tb/fetch_o
add wave -noupdate -divider Registers
add wave -noupdate -color {Medium Slate Blue} -format Literal -label SP -radix hexadecimal /light8080_tb/cpu/SP
add wave -noupdate -color {Indian Red} -format Literal -label PC -radix hexadecimal /light8080_tb/cpu/PC004
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -label PSW -radix binary /light8080_tb/cpu/flag_reg
add wave -noupdate -color {Dark Green} -format Literal -label ACC -radix hexadecimal /light8080_tb/cpu/rbank(7)
add wave -noupdate -color Pink -format Literal -itemcolor Pink -label BC -radix hexadecimal /light8080_tb/cpu/BC
add wave -noupdate -color {Indian Red} -format Literal -itemcolor {Indian Red} -label DE -radix hexadecimal /light8080_tb/cpu/DE
add wave -noupdate -color {Yellow Green} -format Literal -itemcolor {Yellow Green} -label HL -radix hexadecimal /light8080_tb/cpu/HL
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18600000 ps} 0}
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
WaveRestoreZoom {13303347 ps} {23802163 ps}
