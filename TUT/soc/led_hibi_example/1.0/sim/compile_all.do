# Script compiles all vhdl-files and generates a makefile for them
# This script is tested for Modelsim version 6.6a 

.main clear

echo " Generating libraries for files"

echo "Processing component TUT:ip.hwp.interface:led_packet_codec:1.0"
echo "Processing file set hdlSources of component TUT:ip.hwp.interface:led_packet_codec:1.0."
echo " Adding library work"
vlib work
vcom -quiet -check_synthesis D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/led_packet_codec/1.0/vhd/led_packet_codec.vhd

echo "Processing component TUT:ip.hwp.interface:clk_gen:1.0"
echo "Processing file set behavioral of component TUT:ip.hwp.interface:clk_gen:1.0."
vcom -check_synthesis D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/clock/1.0/vhd/clk_gen.vhd

echo "Processing component TUT:ip.hwp.interface:rst_gen:1.0"
echo "Processing file set behavioral of component TUT:ip.hwp.interface:rst_gen:1.0."
vcom  D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/reset/1.0/vhd/rst_gen.vhd

echo "Processing component TUT:ip.hwp.interface:switch_packet_codec:1.0"
echo "Processing file set hdlSources of component TUT:ip.hwp.interface:switch_packet_codec:1.0."
vcom -quiet -check_synthesis D:/user/ege/Svn/daci_ip/trunk/ip.hwp.interface/switch_packet_codec/1.0/vhd/switch_packet_codec.vhd

echo "Processing component TUT:ip.hwp.communication:hibi_segment_small:3.0"
echo "Processing file set hdlSources of component TUT:ip.hwp.communication:hibi_segment_small:3.0."
echo " Adding library hibi"
vlib hibi
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/hibiv3_pkg.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/addr_data_demux_read.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/addr_data_mux_write.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/addr_decoder.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/cfg_init_pkg.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/cfg_mem.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/double_fifo_demux_wr.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/double_fifo_mux_rd.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/dyn_arb.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/fifo_demux_wr.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/fifo_mux_rd.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/lfsr.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/receiver.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/rx_control.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/transmitter.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/tx_control.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/hibi_wrapper_r1.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/hibi_wrapper_r3.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/hibi_wrapper_r4.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/hibi_segment_small.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.communication/hibi/3.0/vhd/hibi_segment_v3.vhd
echo "Processing file set fifo_rtl of component TUT:ip.hwp.communication:hibi_segment_small:3.0."
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.storage/fifos/fifo/1.0/vhd/fifo.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.storage/fifos/multiclk_fifo/1.0/vhd/mixed_clk_fifo_v3.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.storage/fifos/multiclk_fifo/1.0/vhd/multiclk_fifo.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.storage/fifos/multiclk_fifo/1.0/vhd/re_pulse_synchronizer.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.storage/fifos/multiclk_fifo/1.0/vhd/we_pulse_synchronizer.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.storage/fifos/synchronizer/1.0/vhd/aif_we_top.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.storage/fifos/synchronizer/1.0/vhd/aif_read_in.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.storage/fifos/synchronizer/1.0/vhd/aif_read_out.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.storage/fifos/synchronizer/1.0/vhd/aif_read_top.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.storage/fifos/synchronizer/1.0/vhd/aif_we_in.vhd
vcom -work hibi -check_synthesis -quiet D:/user/ege/Svn/daci_ip/trunk/ip.hwp.storage/fifos/synchronizer/1.0/vhd/aif_we_out.vhd

echo "Processing component TUT:soc:led_hibi_example:1.0"
echo "Processing file set structural_vhdlSource of component TUT:soc:led_hibi_example:1.0."
vcom -quiet -check_synthesis -work work D:/user/ege/Svn/daci_ip/trunk/soc/led_hibi_example/1.0/vhd/led_hibi_example.vhd

echo " Creating a new Makefile"

# remove the old makefile
rm -f Makefile
vmake work > Makefile
echo " Script has been executed "
