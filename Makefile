###############################################################
#
# Purpose: Makefile for jpeg sniffer
# Author.: Rene Doss (red)
# Version: 0.1
# License: Dossmatik GmbH
#
###############################################################




all:   huffman jpeg_tb 
	ghdl -e -Wa,--32 -Wl,-m32 jpeg_tb 
	ghdl -r jpeg_tb --stop-time=18000ns --wave=jpeg.ghw
clean:
	ghdl --clean	



huffman: huffman_decoder.vhd 
	ghdl -a -Wa,--32 huffman_decoder.vhd
	ghdl -a -Wa,--32 jpeg_tb.vhd

jpeg_tb: jpeg_tb.vhd huffman_decoder.vhd
	ghdl -a -Wa,--32 jpeg_tb.vhd