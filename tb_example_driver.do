# Filename:     tb_example_driver.do
# Filetype:     Modelsim Script File
# Date:         26 oct 2012
# Update:       -
# Description:  Script File For Automatic Simulation
# Author:       J. op den Brouw
# State:        Demo
# Error:        -
# Version:      1.1aplha
# Copyright:    (c)2012, De Haagse Hogeschool

# This ModelSim command file houses all commands for tracing
# the client side module driver alias the test hardware.

# Set transcript on
transcript on

# Recreate the work directory and map to work
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

# Find out if we're started through Quartus or by hand
# (or by using an exec in the Tcl window in Quartus).
# Quartus has the annoying property that it will start
# Modelsim from a directory called "simulation/modelsim".
# The design and the testbench are located in the project
# root, so we've to compensate for that.
if [ string match "*simulation/modelsim" [pwd] ] { 
	set prefix "../../"
	puts "Running Modelsim from Quartus..."
} else {
	set prefix ""
	puts "Running Modelsim..."
}

# Compile the LCD VHDL description and testbench,
# please note that the design and its testbench are located
# in the project root, but the simulator start in directory
# <project_root>/simulation/modelsim, so we have to compensate
# for that.
vcom -2008 -work work ${prefix}lcd_driver_hd44780_module.vhd
vcom -2008 -work work ${prefix}example_driver.vhd
vcom -2008 -work work ${prefix}tb_example_driver.vhd

# Start the simulator with 1 ns time resolution
vsim -t 1ns -L rtl_work -L work -voptargs="+acc" tb_example_driver

# Log all signals in the design, good if the number
# of signals is small.
add log -r *

# Add all toplevel signals
# Add a number of signals of the simulated design
add wave -divider "SYSTEM"
add wave CLOCK_50
add wave -divider "Inputs"
add wave BUTTON
add wave -divider "Internals"
add wave de0/areset
add wave de0/clk
add wave de0/state
add wave de0/busy
add wave de0/wr
add wave de0/goto10
add wave de0/goto20
add wave de0/goto30
add wave de0/home
add wave de0/cls
add wave de0/line_counter
add wave de0/character_counter
add wave -divider "Outputs"
add wave LCD_EN
add wave LCD_RW
add wave LCD_RS
add wave LCD_DATA
add wave LEDG(0)

# Open Structure, Signals (waveform) and List window
view structure
#view list
view signals
view wave

# Run simulation for ...
# Note 60 ms is sufficient if using Busy Flag reading, 270 ms
# for non-BF reading
run 270 ms

# Fill up the waveform in the window
wave zoom full
