vlib work
vlog ../rtl/*.v +incdir+../rtl
vlog *.v
vsim -novopt test_point_scalar_mult
add wave -noupdate -format Logic -radix unsigned /test_point_scalar_mult/clk
add wave -noupdate -format Logic -radix unsigned /test_point_scalar_mult/reset
add wave -noupdate -divider input
add wave -noupdate -format Logic -radix unsigned /test_point_scalar_mult/zero1
add wave -noupdate -format Literal -radix hexadecimal /test_point_scalar_mult/x1
add wave -noupdate -format Literal -radix hexadecimal /test_point_scalar_mult/y1
add wave -noupdate -format Literal -radix decimal /test_point_scalar_mult/c
add wave -noupdate -divider output
add wave -noupdate -format Logic -radix unsigned /test_point_scalar_mult/done
add wave -noupdate -format Logic -radix unsigned /test_point_scalar_mult/zero3
add wave -noupdate -format Literal -radix hexadecimal /test_point_scalar_mult/x3
add wave -noupdate -format Literal -radix hexadecimal /test_point_scalar_mult/y3
run -all
