vlib work
# packages
vcom -93 ../../../../../bench/vhdl/images-body.vhd 
vcom -93 ../../../../../bench/vhdl/txt_util.vhd
# DUT
vcom -93 ../../../../../rtl/vhdl/PCK_CRC8_D8.vhd
vcom -93 ../../../../../rtl/vhdl/PCK_CRC32_D32.vhd
vcom -93 ../../../../../rtl/vhdl/crc_gen.vhd
vcom -93 ../../../../../rtl/vhdl/crc_core.vhd 

# Testbench
vcom -93 ../../../../../bench/vhdl/crc_core_tb.vhd