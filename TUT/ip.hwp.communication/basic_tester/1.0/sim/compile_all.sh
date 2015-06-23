#!/bin/sh
#
# This script compiles all the needed source file and 
# creates a makeifle for also 
#
# Environment variables
#	TMP_DIR 	kertoo mihin hakemistoon kaannetyt fiilut laitetaan.
#	
# Erno Salminen, 2010

clear

if test -z $TMP_DIR
then
	echo "Env variable TMP_DIR, which defines the location of Modelsim's work dir, is not set"
	echo "->Exit"
	exit
fi

mkdir $TMP_DIR

echo "Removing old vhdl library "
rm -rf $TMP_DIR/codelib

echo; echo "Creating a new library at"
echo $TMP_DIR; echo

# Create and map library
vlib $TMP_DIR/codelib
vmap work $TMP_DIR/codelib


echo; echo "Compiling HIBI network"; echo

vcom -quiet -check_synthesis -pedanticerrors ../../../../ip.hwp.storage/fifos/fifo/1.0/vhd/fifo.vhd
vcom -quiet -check_synthesis -pedanticerrors ../../../../ip.hwp.storage/fifos/multiclk_fifo/1.0/vhd/multiclk_fifo.vhd


HIBI_DIR="../../../hibi/3.0/vhd"
vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/hibiv3_pkg.vhd

vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/addr_decoder.vhd
vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/addr_data_demux_read.vhd
vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/addr_data_mux_write.vhd

vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/cfg_init_pkg.vhd
vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/cfg_mem.vhd
vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/dyn_arb.vhd
vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/lfsr.vhd

vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/double_fifo_demux_wr.vhd
vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/double_fifo_mux_rd.vhd
vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/fifo_mux_rd.vhd
vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/fifo_demux_wr.vhd


vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/rx_control.vhd
vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/tx_control.vhd
vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/receiver.vhd
vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/transmitter.vhd

vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/hibi_wrapper_r1.vhd
vcom -quiet -check_synthesis -pedanticerrors $HIBI_DIR/hibi_wrapper_r4.vhd

echo
echo "Compile basic tester component"
TESTER_DIR="../vhd"
vcom -quiet -check_synthesis -pedanticerrors $TESTER_DIR/txt_util.vhd
vcom -quiet -check_synthesis -pedanticerrors $TESTER_DIR/basic_tester_pkg.vhd
vcom -quiet -check_synthesis -pedanticerrors $TESTER_DIR/basic_tester_rx.vhd
vcom -quiet -check_synthesis -pedanticerrors $TESTER_DIR/basic_tester_tx.vhd



echo; echo "Compiling vhdl testbench";echo
vcom -quiet ../tb/tb_basic_tester.vhd


echo;echo "Creating a new makefile"
rm -f makefile.vhd
vmake $TMP_DIR/codelib > makefile.vhd

echo "To simulate, run"
echo " vsim -novopt work.tb_basic_tester &"
echo ""
echo " --compile all is done-- "