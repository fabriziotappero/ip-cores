#only true IO are zero_o and one_o pins; rest stay on-chip through WB bus
set_property IOSTANDARD LVCMOS18 [get_ports {one_o zero_o}]
#set_property PACKAGE_PIN <pin name here> [get_ports one_o]
#set_property PACKAGE_PIN <pin name here> [get_ports zero_o]

#timing constraints
#only one clock, and it's the WB clock.
create_clock –period 10 [get_ports wb_clk_i]