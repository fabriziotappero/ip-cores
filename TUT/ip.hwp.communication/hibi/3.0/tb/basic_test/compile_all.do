# Compile all that is needed for simple HIBI example
# Lasse Lehtonen, TUT, September 2011


# Define the path to hibi root directory (relative to your current directory)
set root "../.."

# These external components are all relative to that "root"
set mem_dir "../../../ip.hwp.storage/fifos"
set tb_dir "tb/basic_test";

# Define library names
set msimlibs "msim_libs";
set vhdlib "$msimlibs/vhd_lib";






echo "##"
echo "## 1/4 Creating working libraries for Modelsim to $vhdlib"

if {[file exists $msimlibs]} {
   vdel -lib $vhdlib -all
   vlib $vhdlib	
} else {
  mkdir $msimlibs
  vlib $vhdlib	
}

# ES 2012-03-08
vmap work $vhdlib 


echo "##"
echo "## 2/4 Compiling source files"
echo "##"

#
# FIFOs
#

vcom -novopt -quiet -check_synthesis -work $vhdlib $root/$mem_dir/fifo/1.0/vhd/fifo.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib $root/$mem_dir/multiclk_fifo/1.0/vhd/multiclk_fifo.vhd

#
# HIBI files
#
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/hibiv3_pkg.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/fifo_demux_wr.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/fifo_mux_rd.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/double_fifo_demux_wr.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/double_fifo_mux_rd.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/addr_decoder.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/rx_control.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/receiver.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/cfg_init_pkg.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/cfg_mem.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/lfsr.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/dyn_arb.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/tx_control.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/transmitter.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/hibi_wrapper_r1.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/hibi_wrapper_r4.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/hibi_bridge_v2.vhd

vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/hibi_orbus_small.vhd



vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/addr_data_demux_read.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/addr_data_mux_write.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/hibi_wrapper_r3.vhd

vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/vhd/hibiv3_r4.vhd


#
# TB Files
#
echo "##"
echo "## 3/4 Compiling testbench files"
echo "##"
vcom -quiet -check_synthesis -work $vhdlib  $root/../../basic_tester/1.0/vhd/basic_tester_pkg.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/../../basic_tester/1.0/vhd/txt_util.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/../../basic_tester/1.0/vhd/basic_tester_rx.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/../../basic_tester/1.0/vhd/basic_tester_tx.vhd

vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/$tb_dir/tb_basic_test_hibiv3.vhd
vcom -novopt -quiet -check_synthesis -work $vhdlib  $root/$tb_dir/tb_basic_test_hibiv3_wra.vhd

echo "##"
echo "## 4/4 All done"
echo "##"
echo "## To simulate: " 
echo "##   vsim -novopt -lib $vhdlib tb_basic_test_hibiv3"
echo "##   do add_signals.do"
echo "##   run 350ns"
echo "##"