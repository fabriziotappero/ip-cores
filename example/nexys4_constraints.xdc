# The Potato Processor - A simple processor for FPGAs
# (c) Kristian Klomsten Skordal 2014 <kristian.skordal@wafflemail.net>
# Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

# Set operating conditions to improve temperature estimation:
set_operating_conditions -airflow 0
set_operating_conditions -heatsink low

# Clock:
set_property PACKAGE_PIN E3 [get_ports clk]
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

 # Reset:
 set_property PACKAGE_PIN C12 [get_ports reset_n]
 	set_property IOSTANDARD LVCMOS33 [get_ports reset_n]

 # External interrupt button:
 set_property PACKAGE_PIN E16 [get_ports external_interrupt]
 	set_property IOSTANDARD LVCMOS33 [get_ports external_interrupt]

# UART (to host) lines:
set_property PACKAGE_PIN C4 [get_ports uart_rxd]
	set_property IOSTANDARD LVCMOS33 [get_ports uart_rxd]
set_property PACKAGE_PIN D4 [get_ports uart_txd]
	set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]

# Switches:
set_property PACKAGE_PIN U9 [get_ports {switches[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[0]}]
set_property PACKAGE_PIN U8 [get_ports {switches[1]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[1]}]
set_property PACKAGE_PIN R7 [get_ports {switches[2]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[2]}]
set_property PACKAGE_PIN R6 [get_ports {switches[3]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[3]}]
set_property PACKAGE_PIN R5 [get_ports {switches[4]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[4]}]
set_property PACKAGE_PIN V7 [get_ports {switches[5]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[5]}]
set_property PACKAGE_PIN V6 [get_ports {switches[6]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[6]}]
set_property PACKAGE_PIN V5 [get_ports {switches[7]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[7]}]
set_property PACKAGE_PIN U4 [get_ports {switches[8]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[8]}]
set_property PACKAGE_PIN V2 [get_ports {switches[9]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[9]}]
set_property PACKAGE_PIN U2 [get_ports {switches[10]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[10]}]
set_property PACKAGE_PIN T3 [get_ports {switches[11]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[11]}]
set_property PACKAGE_PIN T1 [get_ports {switches[12]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[12]}]
set_property PACKAGE_PIN R3 [get_ports {switches[13]}]		
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[13]}]
set_property PACKAGE_PIN P3 [get_ports {switches[14]}]		
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[14]}]
set_property PACKAGE_PIN P4 [get_ports {switches[15]}]		
	set_property IOSTANDARD LVCMOS33 [get_ports {switches[15]}]

# LEDs:
set_property PACKAGE_PIN T8 [get_ports {leds[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
set_property PACKAGE_PIN V9 [get_ports {leds[1]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
set_property PACKAGE_PIN R8 [get_ports {leds[2]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]
set_property PACKAGE_PIN T6 [get_ports {leds[3]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]
set_property PACKAGE_PIN T5 [get_ports {leds[4]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[4]}]
set_property PACKAGE_PIN T4 [get_ports {leds[5]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[5]}]
set_property PACKAGE_PIN U7 [get_ports {leds[6]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[6]}]
set_property PACKAGE_PIN U6 [get_ports {leds[7]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[7]}]
set_property PACKAGE_PIN V4 [get_ports {leds[8]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[8]}]
set_property PACKAGE_PIN U3 [get_ports {leds[9]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[9]}]
set_property PACKAGE_PIN V1 [get_ports {leds[10]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[10]}]
set_property PACKAGE_PIN R1 [get_ports {leds[11]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[11]}]
set_property PACKAGE_PIN P5 [get_ports {leds[12]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[12]}]
set_property PACKAGE_PIN U1 [get_ports {leds[13]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[13]}]
set_property PACKAGE_PIN R2 [get_ports {leds[14]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[14]}]
set_property PACKAGE_PIN P2 [get_ports {leds[15]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {leds[15]}]
