#

add wave sim:/cipher/pt
add wave sim:/cipher/key
add wave sim:/cipher/ct
add wave sim:/cipher/cti
add wave sim:/cipher/v
add wave sim:/cipher/nk
add wave sim:/cipher/ldpt
add wave sim:/cipher/ldk
add wave sim:/cipher/ld
add wave sim:/cipher/ldi1
add wave sim:/cipher/ldrs
add wave sim:/cipher/clk
add wave sim:/cipher/cnt
add wave sim:/cipher/ct2b
add wave sim:/cipher/cnts
add wave sim:/cipher/rst
add wave sim:/cipher/crst
add wave sim:/cipher/rsts
add wave sim:/cipher/swp
add wave sim:/cipher/swp1
add wave sim:/cipher/wsb1
add wave sim:/cipher/wsb2
add wave sim:/cipher/wsr
add wave sim:/cipher/wmc
add wave sim:/cipher/ssm
add wave sim:/cipher/last
add wave sim:/cipher/rk
add wave sim:/cipher/int
add wave sim:/cipher/int1
add wave sim:/cipher/int2

force -freeze sim:/cipher/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/cipher/rst 1 0
run 100ns
force -freeze sim:/cipher/rst 0 0
force -freeze sim:/cipher/ldpt 1 0
force -freeze sim:/cipher/ldk 1 0
force -freeze sim:/cipher/nk 0100 0
force -freeze sim:/cipher/pt  x"3243f6a8" 0
force -freeze sim:/cipher/key x"2b7e1516" 0
run 100ns
force -freeze sim:/cipher/pt  x"885a308d" 0
force -freeze sim:/cipher/key x"28aed2a6" 0
run 100ns
force -freeze sim:/cipher/pt  x"313198a2" 0
force -freeze sim:/cipher/key x"abf71588" 0
run 100ns
force -freeze sim:/cipher/pt  x"e0370734" 0
force -freeze sim:/cipher/key x"09cf4f3c" 0
run 100ns
force -freeze sim:/cipher/ldpt 0 0
force -freeze sim:/cipher/ldk 0 0
