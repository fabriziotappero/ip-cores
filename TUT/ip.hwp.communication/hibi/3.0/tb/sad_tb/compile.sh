#!/bin/sh

#
# Compiles all VHDL files and special SystemC test suite.
# 
# Test suite supports both normal mode and simultaneous 
# addr+data (=sad), as well as all commands of HIBI v.3. 
# Moreover, interface revisions r3 and r4 can be tested. 
# 
# Lasse Lehtonen, September 2011



# Define the path to hibi root directory (relative to your current directory)
root="."

# These external components are all relative to that "root"
mem_dir="$root/../../../ip.hwp.storage"
tb_dir="$root/tb/sad_tb"

# Define library names
msimlibs="msim_libs"
vhdlib="$msimlibs/vhd_lib"
n4_sclib="$msimlibs/norm4_sc_lib"
s4_sclib="$msimlibs/sad4_sc_lib"
n3_sclib="$msimlibs/norm3_sc_lib"
s3_sclib="$msimlibs/sad3_sc_lib"

# Define macros compilation commands and flags
com_vhdl="vcom -check_synthesis -lint -pedanticerrors -novopt -work $vhdlib -quiet"

# Flags define normal vs. sad mode, and r3 vs. r4
com_sv_s4="sccom -DHIBI_IN_SAD_MODE -O3 -I $$(tb_dir) -work $s4_sclib -nologo -Wall -incr"
com_sv_n4="sccom -O3 -I $$(tb_dir) -work $n4_sclib -nologo -Wall -incr"

com_sv_s3="sccom -DUSE_R3_WRAPPERS -DHIBI_IN_SAD_MODE -O3 -I $$(tb_dir) -work $s3_sclib -nologo -Wall -incr"
com_sv_n3="sccom -DUSE_R3_WRAPPERS -O3 -I $$(tb_dir) -work $n3_sclib -nologo -Wall -incr"



# Check if directories exist, and create them if necessary
echo "##"

if [ -d "$msimlibs" ]
then
    echo "## 1/5 Modelsim working library directory $msimlibs already exists"        
else
    echo "## 1/5 Creating working libraries for Modelsim in directory $msimlibs"
    mkdir $msimlibs
fi

if [ -d "$vhdlib" ]
then
    echo "##  $vhdlib already exists"
else	
    echo "##  Creating $vhdlib"
    vlib $vhdlib	
fi

if [ -d "$n4_sclib" ]
then
    echo "##  $n4_sclib already exists"
else	
    echo "##  Creating $n4_sclib"
    vlib $n4_sclib	
fi

if [ -d "$s4_sclib" ]
then
    echo "##  $s4_sclib already exists"
else	
    echo "##  Creating $s4_sclib"
    vlib $s4_sclib	
fi


if [ -d "$n3_sclib" ]
then
    echo "##  $n3_sclib already exists"
else	
    echo "##  Creating $n3_sclib"
    vlib $n3_sclib	
fi

if [ -d "$s3_sclib" ]
then
    echo "##  $s3_sclib already present"
else	
    echo "##  Creating $s3_sclib"
    vlib $s3_sclib	
fi


echo "##"
echo "## 2/5 Compiling VHDL source files"
echo "##"

#
# FIFOs
#
$com_vhdl $root/$mem_dir/fifos/fifo/1.0/vhd/fifo.vhd

$com_vhdl $root/$mem_dir/fifos/multiclk_fifo/1.0/vhd//multiclk_fifo.vhd
$com_vhdl $root/$mem_dir/fifos/multiclk_fifo/1.0/vhd//re_pulse_synchronizer.vhd
$com_vhdl $root/$mem_dir/fifos/multiclk_fifo/1.0/vhd//we_pulse_synchronizer.vhd
$com_vhdl $root/$mem_dir/fifos/multiclk_fifo/1.0/vhd//mixed_clk_fifo_v3.vhd

$com_vhdl $root/$mem_dir/fifos/synchronizer/1.0/vhd/aif_read_in.vhd
$com_vhdl $root/$mem_dir/fifos/synchronizer/1.0/vhd/aif_read_out.vhd
$com_vhdl $root/$mem_dir/fifos/synchronizer/1.0/vhd/aif_read_top.vhd
$com_vhdl $root/$mem_dir/fifos/synchronizer/1.0/vhd/aif_we_in.vhd
$com_vhdl $root/$mem_dir/fifos/synchronizer/1.0/vhd/aif_we_out.vhd
$com_vhdl $root/$mem_dir/fifos/synchronizer/1.0/vhd/aif_we_top.vhd

$com_vhdl $root/$mem_dir/fifos/gray_fifo/1.0/vhd/async_dpram.vhd
$com_vhdl $root/$mem_dir/fifos/gray_fifo/1.0/vhd/async_dpram_generic.vhd
$com_vhdl $root/$mem_dir/fifos/gray_fifo/1.0/vhd/gray.vhd
$com_vhdl $root/$mem_dir/fifos/gray_fifo/1.0/vhd/cdc_fifo_ctrl.vhd
$com_vhdl $root/$mem_dir/fifos/gray_fifo/1.0/vhd/cdc_fifo.vhd

#
# HIBI files
#
$com_vhdl $root/vhd/hibiv3_pkg.vhd
$com_vhdl $root/vhd/fifo_demux_wr.vhd
$com_vhdl $root/vhd/fifo_mux_rd.vhd
$com_vhdl $root/vhd/double_fifo_demux_wr.vhd
$com_vhdl $root/vhd/double_fifo_mux_rd.vhd
$com_vhdl $root/vhd/addr_decoder.vhd
$com_vhdl $root/vhd/rx_control.vhd
$com_vhdl $root/vhd/receiver.vhd
$com_vhdl $root/vhd/cfg_init_pkg.vhd
$com_vhdl $root/vhd/cfg_mem.vhd
$com_vhdl $root/vhd/lfsr.vhd
$com_vhdl $root/vhd/dyn_arb.vhd
$com_vhdl $root/vhd/tx_control.vhd
$com_vhdl $root/vhd/transmitter.vhd
$com_vhdl $root/vhd/hibi_wrapper_r1.vhd
$com_vhdl $root/vhd/hibi_wrapper_r4.vhd
$com_vhdl $root/vhd/hibi_bridge_v2.vhd

#$com_vhdl $root/vhd/addr_data_demux_write.vhd
#$com_vhdl $root/vhd/addr_data_mux_read.vhd
#$com_vhdl $root/vhd/hibi_wrapper_r2.vhd

$com_vhdl $root/vhd/addr_data_demux_read.vhd
$com_vhdl $root/vhd/addr_data_mux_write.vhd
$com_vhdl $root/vhd/hibi_wrapper_r3.vhd


echo "##"
echo "## 3/5 Compiling TB  source files (VHDL + SystemC)"
echo "##"
$com_vhdl $root/$tb_dir/hibiv3_r4.vhd
$com_vhdl $root/$tb_dir/hibiv3_r3.vhd
$com_sv_n4 $root/$tb_dir/main.cc
$com_sv_s4 $root/$tb_dir/main.cc
$com_sv_n3 $root/$tb_dir/main.cc
$com_sv_s3 $root/$tb_dir/main.cc

# There may appear couple of warnings "not debuggable" which should do not harm

echo "##"
echo "## 4/5Linking"
echo "##"
sccom -link -work $s4_sclib -lib $s4_sclib -lib $vhdlib -nologo
sccom -link -work $n4_sclib -lib $n4_sclib -lib $vhdlib -nologo
sccom -link -work $s3_sclib -lib $s3_sclib -lib $vhdlib -nologo
sccom -link -work $n3_sclib -lib $n3_sclib -lib $vhdlib -nologo



echo "##"
echo "## 5/5 All done"
echo "##"
echo "## To simulate: "
echo "##  normal mode, R4: vsim -novopt -lib $n4_sclib -L $vhdlib sc_main &"
echo "##  sad mode, R4   : vsim -novopt -lib $s4_sclib -L $vhdlib sc_main &"
echo "##  normal mode, R3: vsim -novopt -lib $n3_sclib -L $vhdlib sc_main &"
echo "##  sad mode, R3   : vsim -novopt -lib $s3_sclib -L $vhdlib sc_main &" 
echo "##"
echo "## Run the simulation until the message SAD HIBI TESTBENCH FINISHED appears, e.g. 3 ms"
echo "## Order (from fastest to slowest): "
echo "##  sad_r4 (1.8 ms), sad_r3 (2 ms), norm (2.5ms), and norm_r4 (2.7ms)  (2011-09-06)"