#
# ModelSim simulation script
#

#
# project color_conv.
#

vlib work

# Compile
vcom -93 -work work ..\\..\\rtl\\vhdl\\ccfactors_pkg.vhd
vcom -93 -work work ..\\..\\rtl\\vhdl\\colorconv.vhd

vcom -93 -work work ..\\..\\bench\\vhdl\\colorconv_tb.vhd

#sim
vsim -t ps tb

###########################################################################
#add wave -noupdate -divider "Color Converter Signals"
add wave -noupdate -format logic /tb/clk
add wave -noupdate -format logic /tb/rstn
add wave -noupdate -format logic /tb/DATA_ENA
add wave -noupdate -format logic /tb/DOUT_RDY
add wave -noupdate -format Literal -radix hexadecimal /tb/x1
add wave -noupdate -format Literal -radix hexadecimal /tb/x2
add wave -noupdate -format Literal -radix hexadecimal /tb/x3
add wave -noupdate -format Literal -radix hexadecimal /tb/y1
add wave -noupdate -format Literal -radix hexadecimal /tb/y2
add wave -noupdate -format Literal -radix hexadecimal /tb/y3

WaveRestoreZoom {0 us} {10 us}
TreeUpdate [SetDefaultTree]
update

set RunLength	{1400 us}

run




