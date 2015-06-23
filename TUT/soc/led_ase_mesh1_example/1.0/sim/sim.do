#
# Runs the simulation. 
# Uses "force" command to toggle the switch signals a couple of times.
#  
# Erno Salminen, Decemeber 2011

.main clear
#vsim -novopt work.led_ase_mesh1_example
vsim  work.led_ase_mesh1_example
do all_waves.do

# Reset and initialize
force /clk 1 0, 0 10 -repeat 20
force /reset_n 0 0, 1 50
force /switch_0_in 0 0
force /switch_1_in 0 0
run 600


# Toggle the switch1
# Led output gets inverted in about dozen clk cycles
force /switch_1_in 1 0, 0 50
run 600
force /switch_1_in 1 0, 0 50
run 600
force /switch_1_in 1 0, 0 50
run 800


# Toggle the other switch
force /switch_0_in 1 0, 0 50
run 600
force /switch_0_in 1 0, 0 50
run 600
force /switch_0_in 1 0, 0 50
run 800


# Toggle both switches
force /switch_0_in 1 0, 0 50
force /switch_1_in 1 0, 0 50
run 600

