vlib work
vlog -lint ../rtl/*.v
vlog -lint *.v
vsim -novopt test_keccak
add wave -noupdate -format Logic -radix unsigned /test_keccak/clk
add wave -noupdate -format Logic -radix unsigned /test_keccak/reset
add wave -noupdate -divider input
add wave -noupdate -format Literal -radix hexadecimal /test_keccak/in
add wave -noupdate -format Literal -radix unsigned /test_keccak/byte_num
add wave -noupdate -format Literal -radix unsigned /test_keccak/in_ready
add wave -noupdate -format Literal -radix unsigned /test_keccak/is_last
add wave -noupdate -divider output
add wave -noupdate -format Literal -radix unsigned /test_keccak/ack
add wave -noupdate -format Literal -radix hexadecimal /test_keccak/out
add wave -noupdate -format Literal -radix unsigned /test_keccak/out_ready
run -all
