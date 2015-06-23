# Compile PS2 Design

vcom ../../rtl/vhdl/ps2.vhd
vcom ../../rtl/vhdl/ps2_test.vhd
vcom ../../rtl/vhdl/ps2_wishbone.vhd

# Compile Testbeches

vcom -93 ../vhdl/ps2_mouse.vhd
vcom -93 ../vhdl/wb_test.vhd
vcom -93 ../vhdl/wb_ps2_tb.vhd

