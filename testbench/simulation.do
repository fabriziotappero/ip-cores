vlib work
vlog ../rtl/*.v +incdir+../rtl
vlog *.v
vsim -novopt test_tate_pairing
add wave -noupdate -format Logic -radix unsigned /test_tate_pairing/clk
add wave -noupdate -format Logic -radix unsigned /test_tate_pairing/reset
add wave -noupdate -divider input
add wave -noupdate -format Literal -radix hexadecimal /test_tate_pairing/x1
add wave -noupdate -format Literal -radix hexadecimal /test_tate_pairing/y1
add wave -noupdate -format Literal -radix hexadecimal /test_tate_pairing/x2
add wave -noupdate -format Literal -radix hexadecimal /test_tate_pairing/y2
add wave -noupdate -divider output
add wave -noupdate -format Logic -radix unsigned /test_tate_pairing/done
add wave -noupdate -format Literal -radix hexadecimal /test_tate_pairing/out
run -all
