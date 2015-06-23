# Tests N2H2 reception 
#
# Compiles all files, starts simulation and adds signals to wave window
#
# The traffic is configured with following ASCII file formats:
#
# tbrx_conf_hibisend.dat : dest_agent delay_cycles num_of_words
#
# tbrx_conf_rx.dat       : mem_addr, noc_addr, irq_amount (=words to receive)
# tbrx_data_file.dat     : mem_addr, noc_addr, irq_amount (=words to receive)
#
#



quit -sim

vlib work

# HW files

vcom -check_synthesis -pedantic ../vhd/hpd_rx_channel.vhd
vcom -check_synthesis -pedantic ../vhd/hpd_rx_and_conf.vhd
vcom -check_synthesis -pedantic ../vhd/hpd_tx_control.vhd
vcom -check_synthesis -pedantic ../vhd/hibi_pe_dma.vhd


# TB files

vcom ./blocks/txt_util.vhd
vcom ./blocks/fifo.vhd
vcom ./blocks/tb_n2h2_pkg.vhd
vcom ./blocks/hibi_sender_n2h2.vhd
vcom ./blocks/avalon_cfg_reader.vhd
vcom ./blocks/avalon_cfg_writer.vhd
vcom ./blocks/avalon_reader.vhd
vcom ./blocks/sram_scalable_v3.vhd
vcom ./blocks/tb_n2h2_rx.vhd


# Start simulation

vsim -t 1ns -novopt work.tb_n2h2_rx
do ./blocks/wave_tb_n2h2_rx.do 