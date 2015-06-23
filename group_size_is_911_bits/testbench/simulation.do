vlib work
vlog ../rtl/*.v
vlog *.v
vsim -novopt test_pairing
add wave -noupdate -format Logic -radix unsigned /test_pairing/clk
add wave -noupdate -format Logic -radix unsigned /test_pairing/reset
add wave -noupdate -divider input
add wave -noupdate -format Logic -radix unsigned /test_pairing/sel
add wave -noupdate -format Logic -radix unsigned /test_pairing/w
add wave -noupdate -format Literal -radix hexadecimal /test_pairing/addr
add wave -noupdate -format Logic -radix unsigned /test_pairing/update
add wave -noupdate -format Logic -radix unsigned /test_pairing/ready
add wave -noupdate -format Logic -radix unsigned /test_pairing/i
add wave -noupdate -divider output
add wave -noupdate -format Logic -radix unsigned /test_pairing/done
add wave -noupdate -format Logic -radix unsigned /test_pairing/o
run -all
