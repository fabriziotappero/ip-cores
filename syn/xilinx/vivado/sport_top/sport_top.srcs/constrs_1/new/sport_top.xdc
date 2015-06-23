#only true IO are zero_o and one_o pins; rest stay on-chip through WB bus
set_property IOSTANDARD LVCMOS18 [get_ports {DTxPRI DTxSEC TSCLKx TFSx DRxPRI DRxSEC RSCLKx RFSx}]  
#set_property PACKAGE_PIN <pin name here> [get_ports DTxPRI]
#set_property PACKAGE_PIN <pin name here> [get_ports DTxSEC]
#set_property PACKAGE_PIN <pin name here> [get_ports TSCLKx]
#set_property PACKAGE_PIN <pin name here> [get_ports TFSx]
#set_property PACKAGE_PIN <pin name here> [get_ports DRxPRI]
#set_property PACKAGE_PIN <pin name here> [get_ports DRxSEC]
#set_property PACKAGE_PIN <pin name here> [get_ports RSCLKx]
#set_property PACKAGE_PIN <pin name here> [get_ports RFSx]

#timing constraints
#3 independant clocks; wb_clk drives WB; rxclk drives rx logic, txclk drivves tx logic
#data flowing between the clock domains is gated with dual port FIFOs
#config data that will change infrequently and is seen as static by other clock domains is gated with FF
create_clock -period 10 [get_ports wb_clk_i]
create_clock -period 20 [get_ports rxclk]
create_clock -period 20 [get_ports txclk]
