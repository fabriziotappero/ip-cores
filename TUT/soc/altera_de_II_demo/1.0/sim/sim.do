#
# Runs the simulation. 
# Uses "force" command to toggle the switch signals a couple of times.
#  
# Erno Salminen, Decemeber 2011

.main clear
vsim  work.altera_de_ii_demo

do all_waves.do


# Reset and initialize
force /clk 1 0, 0 10 -repeat 20
force /rst_n 0 0, 1 50
force /toggle_in 0 0
run 600


# Toggle assigns enable=1
force /toggle_in 1 0, 0 50 ms
run 400 ms

# Toggle assigns enable=0
force /toggle_in 1 0, 0 50 ms
run 400 ms

# Toggle assigns enable=1 again
force /toggle_in 1 0, 0 50 ms
run 400 ms


