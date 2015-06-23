vlib work
# packages
vcom -93 ../../../../../rtl/vhdl/opb_spi_slave_pack.vhd

# DUT
vcom -93 ../../../../../rtl/vhdl/bin2gray.vhd
vcom -93 ../../../../../rtl/vhdl/gray2bin.vhd
vcom -93 ../../../../../rtl/vhdl/gray_adder.vhd
vcom -93 ../../../../../rtl/vhdl/fifo_prog_flags.vhd
vcom -93 ../../../../../rtl/vhdl/ram.vhd
vcom -93 ../../../../../rtl/vhdl/fifo.vhd
vcom -93 ../../../../../rtl/vhdl/opb_m_if.vhd
vcom -93 ../../../../../rtl/vhdl/opb_if.vhd
vcom -93 ../../../../../rtl/vhdl/opb_m_if.vhd
vcom -93 ../../../../../rtl/vhdl/shift_register.vhd
vcom -93 ../../../../../rtl/vhdl/irq_ctl.vhd
vcom -93 ../../../../../rtl/vhdl/PCK_CRC8_D8.vhd
vcom -93 ../../../../../rtl/vhdl/PCK_CRC32_D32.vhd
vcom -93 ../../../../../rtl/vhdl/crc_gen.vhd
vcom -93 ../../../../../rtl/vhdl/crc_core.vhd 
vcom -93 ../../../../../rtl/vhdl/opb_spi_slave.vhd

# Testbench
vcom -93 ../../../../../bench/vhdl/opb_spi_slave_tb.vhd