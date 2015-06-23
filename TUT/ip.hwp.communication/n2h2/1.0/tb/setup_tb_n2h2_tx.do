
quit -sim

vlib work

# HW files

vcom -check_synthesis -pedantic ../vhd/one_hot_mux.vhd
vcom -check_synthesis -pedantic ../vhd/step_counter2.vhd
vcom -check_synthesis -pedantic ../vhd/n2h2_rx_chan.vhd
vcom -check_synthesis -pedantic ../vhd/n2h2_rx_channels.vhd
vcom -check_synthesis -pedantic ../vhd/n2h2_tx_vl.vhd
vcom -check_synthesis -pedantic ../vhd/n2h2_chan.vhd


# TB files


vcom ./blocks/sram_scalable_v3.vhd
vcom ./blocks/tb_n2h2_tx.vhd

vsim -t 1ns work.tb_n2h2_tx
do blocks/wave_tb_n2h2_tx.do