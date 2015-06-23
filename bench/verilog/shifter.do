add wave -noupdate -format Literal -radix ascii yacc_test.cpu.d1.inst
add wave -noupdate -format Logic yacc_test.cpu.d1.clock
add wave -noupdate -format  Literal -offset 0 -radix symbolic yacc_test.cpu.pipe.sh1.shift_func
add wave -noupdate -format Literal -radix hexadecimal yacc_test.cpu.pipe.sh1.a
add wave -noupdate -format Literal -radix hexadecimal yacc_test.cpu.pipe.sh1.shift_amount
add wave -noupdate -format Literal -radix hexadecimal yacc_test.cpu.pipe.sh1.shift_out
configure wave -namecolwidth 150
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
