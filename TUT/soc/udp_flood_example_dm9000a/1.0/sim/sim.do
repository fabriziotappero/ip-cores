#
# Runs the simulation. 
# Uses "force" command to toggle the switch signals a couple of times.
#  
# Erno Salminen, Decemeber 2011

.main clear
vsim -t 1ps -novopt work.udp_flood_example_dm9000a

do all_waves.do


# Reset and initialize
force /clk_in_CLK 1 0 ns, 0 25 ns -repeat 50 ns
force /rst_n_RESETn 0 0, 1 1200 ns
run 1600 ns


run 23 ms

# Pretend that Eth chip responds that link is up, when init 
# module reads it.
force /udp_flood_example_dm9000a/DM9000A_eth_data_inout(6) 1

run 1 ms

