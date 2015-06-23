#
# Run simulation in Modelsim. 
# Very simple stimulus, just toggle the switches
# few times and that's it. 
#
# Erno Salminen, March 2012

.main clear

#restart -f
vsim work.led_hibi_example
do add_waves.do *
# add wave *

# Initialize evertyhing
#force /clk 1 0, 0 10 -repeat 20
#force /rst_n 0 0, 1 100

force /switch_0_in 0 0
run 1000


# Switches 0,1,2,3
force /switch_0_in 1 0, 0 500
run 1200
force /switch_0_in 1 0, 0 500
run 1200

#force /switch_1_in 1 0, 0 500
#run 1200
#force /switch_1_in 1 0, 0 500
#run 1200

#force /switch_2_in 1 0, 0 500
#run 1200
#force /switch_2_in 1 0, 0 500
#run 1200

#force /switch_3_in 1 0, 0 500
#run 1200
#force /switch_3_in 1 0, 0 500
#run 1200


# Switches 4, 5, 6, 7
#force /switch_4_in 1 0, 0 500
#run 2000



# Switches 0 and 4 at the same time
force /switch_0_in 1 0, 0 500
# force /switch_4_in 1 0, 0 500
run 2000
force /switch_0_in 1 0, 0 500
#force /switch_4_in 1 0, 0 500
run 2000
