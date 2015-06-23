#!/bin/bash

#
# Compile all vhdl codes and create makefile for udp2hibi
# 
# Jussi Nieminen, 2009

FLAGS="-check_synthesis -quiet"

# Paths to files
VHD_DIR="../vhd"
TB_DIR="../tb"
FIFO_DIR="../../../../ip.hwp.storage/fifos"
HIBI_DIR="../../../../ip.hwp.communication/hibi/3.0/vhd"
TG_DIR="../../../../ip.hwp.communication/traffic_generator/vhd"
#FIFO_DIR="../../../memories/fifos"
#HIBI_DIR="../../../interconnections/hibi/vhd"
#TG_DIR="../../../interconnections/traffic_generator/vhd"
LIB="library"

echo -e "\n1 Resetting working library..."

rm -r $LIB
vlib $LIB
vmap work $LIB


echo '2 Compiling files...'

# fifos
vcom $FLAGS $FIFO_DIR/fifo/1.0/vhd/fifo.vhd
vcom $FLAGS $FIFO_DIR/multiclk_fifo/1.0/vhd/multiclk_fifo_v3.vhd

# sub blocks
vcom $FLAGS $VHD_DIR/udp2hibi_pkg.vhd
vcom $FLAGS $VHD_DIR/hibi_receiver.vhd
vcom $FLAGS $VHD_DIR/ctrl_regs.vhd
vcom $FLAGS $VHD_DIR/tx_ctrl.vhd
vcom $FLAGS $VHD_DIR/rx_ctrl.vhd
vcom $FLAGS $VHD_DIR/hibi_transmitter.vhd

# toplevel
vcom $FLAGS $VHD_DIR/udp2hibi.vhd

echo '3 Compiling testbenches...'
vcom $FLAGS $TB_DIR/tb_hibi_receiver.vhd
vcom $FLAGS $TB_DIR/tb_ctrl_regs.vhd
vcom $FLAGS $TB_DIR/tb_tx_ctrl.vhd
vcom $FLAGS $TB_DIR/tb_udp2hibi.vhd
vcom $FLAGS $TB_DIR/tb_rx_ctrl.vhd
vcom $FLAGS $TB_DIR/tb_hibi_transmitter.vhd

if [ $1 = "hibi" ]
then

	echo '3b Compiling hibi...'


#	vcom $FLAGS ../../../interconnections/monitor/vhd/mon_pkg.vhd
#	vcom $FLAGS $HIBI_DIR/hibiv2_pkg.vhd
	vcom $FLAGS $HIBI_DIR/hibiv3_pkg.vhd
	vcom $FLAGS $HIBI_DIR/addr_data_mux_write.vhd
	vcom $FLAGS $HIBI_DIR/addr_data_demux_read.vhd
	vcom $FLAGS $HIBI_DIR/fifo_mux_rd.vhd
	vcom $FLAGS $HIBI_DIR/fifo_demux_wr.vhd
	vcom $FLAGS ../../../../ip.hwp.storage/fifos/fifo/1.0/vhd/fifo.vhd
	vcom $FLAGS $HIBI_DIR/lfsr.vhd

	vcom $FLAGS $HIBI_DIR/double_fifo_mux_rd.vhd
	vcom $FLAGS $HIBI_DIR/double_fifo_demux_wr.vhd
	vcom $FLAGS $HIBI_DIR/dyn_arb.vhd
	vcom $FLAGS $HIBI_DIR/cfg_init_pkg.vhd
	vcom $FLAGS $HIBI_DIR/cfg_mem.vhd

#	vcom $FLAGS $HIBI_DIR/addr_decoder_limits.vhd
	vcom $FLAGS $HIBI_DIR/rx_control.vhd
	vcom $FLAGS $HIBI_DIR/receiver.vhd
	vcom $FLAGS $HIBI_DIR/tx_control.vhd
	vcom $FLAGS $HIBI_DIR/transmitter.vhd
	vcom $FLAGS $HIBI_DIR/hibi_wrapper_r1.vhd
	vcom $FLAGS $HIBI_DIR/hibi_wrapper_r3.vhd
	vcom $FLAGS $HIBI_DIR/hibi_wrapper_r4.vhd
	vcom $FLAGS $HIBI_DIR/hibi_bridge_v2.vhd

#	vcom $FLAGS $TG_DIR/hibi_addr_pkg.vhd
#	vcom $FLAGS $TG_DIR/hibiv2.vhd
	vcom $FLAGS $HIBI_DIR/hibi_segment_v3.vhd

	vcom $FLAGS $TB_DIR/tb_hibi_test.vhd

fi

echo '4 Making the makefile...'
vmake $LIB > makefile



echo ' '
echo 'Done.'
echo 'Simulate with command vsim -novopt tb_udp2hibi and execute ~20 000 ns'