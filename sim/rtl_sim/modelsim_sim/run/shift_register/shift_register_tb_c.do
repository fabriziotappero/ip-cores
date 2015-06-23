vlib work
# packages
vcom -93 ../../../../../rtl/vhdl/opb_spi_slave_pack.vhd
# DUT
vcom -93 ../../../../../rtl/vhdl/shift_register.vhd
# Testbench
vcom -93 ../../../../../bench/vhdl/tx_fifo_emu.vhd
vcom -93 ../../../../../bench/vhdl/rx_fifo_emu.vhd
vcom -93 ../../../../../bench/vhdl/shift_register_tb.vhd