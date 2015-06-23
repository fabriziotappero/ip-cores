quit -sim

vlib altera
vdel -lib altera -all
vlib work
vdel -lib work -all

vlib altera
vlog -work altera altera_mf.v
vlog -work altera ../../par/altera/ip/dcfifo_128b_16.v

vlib work
vlog -work work ../../rtl/tsu/tsu.v
vlog -work work ../../rtl/tsu/ptp_parser.v
vlog -work work ../../rtl/tsu/ptp_queue.v +initreg+0 +incdir+../../par/altera/ip
vlog -work work gmii_rx_bfm.v
vlog -work work gmii_tx_bfm.v
vlog -work work tsu_queue_tb.v
vsim -novopt -L altera work.tsu_queue_tb

log -r */*
radix -hexadecimal
do wave.do

run -all
