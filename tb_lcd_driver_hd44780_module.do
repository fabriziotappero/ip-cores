# Filename:     tb_lcd_driver_hd44780_module.do
# Filetype:     Modelsim Script File
# Date:         66 oct 2012
# Update:       -
# Description:  Script File For Automatic Simulation
# Author:       J. op den Brouw
# State:        Demo
# Error:        -
# Version:      1.1alpha
# Copyright:    (c)2012, De Haagse Hogeschool

# This ModelSim command file houses all commands for tracing
# the LCD Module Driver.

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
# please note that the design and its testbench is located
# in the project root, but the simulator start in directory
# <project_root>/simulation/modelsim, so we have to compensate
# for that.
vcom -2008 -work work ${prefix}lcd_driver_hd44780_module.vhd
vcom -2008 -work work ${prefix}tb_lcd_driver_hd44780_module.vhd

# Start the simulator with 1 ns time resolution
vsim -t 1ns -L rtl_work -L work -voptargs="+acc" tb_lcd_driver_hd44780_module

# Log all signals in the design, good if the number
# of signals is small.
add log -r *

# Add all toplevel signals
# Add a number of signals of the simulated design
#add list *

# Add all toplevel signals
# Add a number of signals of the simulated design
add wave -divider "SYSTEM"
add wave clk
add wave areset
add wave -divider "Inputs"
add wave init
add wave cls
add wave home
add wave goto10
add wave goto20
add wave goto30
add wave wr
add wave data
add wave -divider "Internals"
add wave lcdm/current_state
add wave lcdm/return_state
add wave lcdm/delay_counter
add wave lcdm/use_bf_int
add wave trace
add wave -divider "Outputs"
add wave busy
add wave LCD_E
add wave LCD_RW
add wave LCD_RS
add wave LCD_DB

# Open Structure, Signals (waveform) and List window
view structure
#view list
view signals
view wave

# Run simulation for ...
# Note: 60 ms is sufficient using Busy Flag reading.
run 160 ms

# Fill up the waveform in the window
wave zoom full
