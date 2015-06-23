add wave -noupdate -format Literal -radix ascii yacc_test.cpu.d1.inst
add wave -noupdate -format Literal -radix ascii yacc_test.cpu.d1.instD1
add wave -noupdate -format Logic yacc_test.cpu.pipe.clock
add wave -noupdate -format  Literal -offset 0 -radix symbolic yacc_test.cpu.d1.destination_addrD1
add wave -noupdate -format  Literal -offset 0 -radix symbolic yacc_test.cpu.pipe.dest_addrD2
add wave -noupdate -format  Literal -offset 0 -radix symbolic yacc_test.cpu.pipe.dadrD3
add wave -noupdate -format  Literal -offset 0 -radix symbolic yacc_test.cpu.pipe.dadrD4
add wave -noupdate -format  Literal -offset 0 -radix symbolic yacc_test.cpu.pipe.dadrD5
add wave -noupdate -format  Literal -offset 0 -radix symbolic yacc_test.cpu.pipe.source_addr
add wave -noupdate -format  Literal -offset 0 -radix symbolic yacc_test.cpu.pipe.target_addr
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
