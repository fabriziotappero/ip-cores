restart

force -freeze sim:/fuzzycore/clk 1 0,0 {5ns} -r 10ns

set rst sim:/fuzzycore/rst
set x sim:/fuzzycore/x
set y sim:/fuzzycore/y
set model sim:/fuzzycore/model
set inference sim:/fuzzycore/inference
set done sim:/fuzzycore/done

force rst 0
force x 64'h0
force y 64'h0
force model 0
force inference 0

run 10ns

force rst 1

run 10ns

force rst 0

foreach a {64'hffff993300000000 64'h000066cccc660000 64'h000000003399ffff} b {64'hffb66d2400000000 64'h004992dbdb924900 64'h00000000246db6ff} {
	force x $a
	force y $b
	force model 1
	
	while {[exam done] != 1} {
		run 10ns
	}
	force model 0
	run 10ns
}

force x 64'h00000000ff000000
force inference 1

while {[exam done] != 1} {
	run 10ns
}
