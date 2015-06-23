onerror {resume}
quietly WaveActivateNextPane {} 0
quietly virtual signal -install /light8080_tb1/uut { (context /light8080_tb1/uut )(rbank(14) &rbank(15) )} SP
quietly virtual signal -install /light8080_tb1/uut { (context /light8080_tb1/uut )(rbank(8) &rbank(9) )} PC004
quietly virtual signal -install /light8080_tb1/uut { (context /light8080_tb1/uut )(rbank(0) &rbank(1) )} BC
quietly virtual signal -install /light8080_tb1/uut { (context /light8080_tb1/uut )(rbank(2) &rbank(3) )} DE
quietly virtual signal -install /light8080_tb1/uut { (context /light8080_tb1/uut )(rbank(4) &rbank(5) )} HL
add wave -noupdate -divider External
add wave -noupdate -format Logic /light8080_tb1/clk
add wave -noupdate -format Logic /light8080_tb1/halt_o
add wave -noupdate -color {Medium Sea Green} -format Logic /light8080_tb1/inte_o
add wave -noupdate -color Firebrick -format Logic /light8080_tb1/intr_i
add wave -noupdate -color White -format Logic /light8080_tb1/inta_o
add wave -noupdate -color {Lime Green} -format Literal -radix hexadecimal /light8080_tb1/data_i
add wave -noupdate -color {Cadet Blue} -format Literal -radix hexadecimal /light8080_tb1/data_o
add wave -noupdate -format Literal -radix hexadecimal /light8080_tb1/addr_o
add wave -noupdate -format Logic /light8080_tb1/vma_o
add wave -noupdate -format Logic /light8080_tb1/rd_o
add wave -noupdate -format Logic /light8080_tb1/wr_o
add wave -noupdate -format Logic /light8080_tb1/fetch_o
add wave -noupdate -divider Registers
add wave -noupdate -color {Medium Slate Blue} -format Literal -label SP -radix hexadecimal /light8080_tb1/uut/SP
add wave -noupdate -color {Indian Red} -format Literal -label PC -radix hexadecimal /light8080_tb1/uut/PC004
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -label PSW -radix binary /light8080_tb1/uut/flag_reg
add wave -noupdate -color {Dark Green} -format Literal -label ACC -radix hexadecimal /light8080_tb1/uut/rbank(7)
add wave -noupdate -color Pink -format Literal -itemcolor Pink -label BC -radix hexadecimal /light8080_tb1/uut/BC
add wave -noupdate -color {Indian Red} -format Literal -itemcolor {Indian Red} -label DE -radix hexadecimal /light8080_tb1/uut/DE
add wave -noupdate -color {Yellow Green} -format Literal -itemcolor {Yellow Green} -label HL -radix hexadecimal /light8080_tb1/uut/HL
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
