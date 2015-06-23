
quit -sim

vlib work

# HW files

vcom -check_synthesis -pedantic ../vhd/hpd_rx_channel.vhd
vcom -check_synthesis -pedantic ../vhd/hpd_rx_and_conf.vhd
vcom -check_synthesis -pedantic ../vhd/hpd_tx_control.vhd
vcom -check_synthesis -pedantic ../vhd/hibi_pe_dma.vhd

# TB files

vcom ./blocks/sram_scalable_v3.vhd
vcom ./blocks/tb_n2h2_tx_str.vhd

vsim -novopt -t 1ns work.tb_n2h2_tx
do blocks/wave_tb_n2h2_tx_str.do