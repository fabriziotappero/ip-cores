
set need_quit 1
set need_del  1 

set debug 1

if {$debug} {
	set opt novopt 
} else {
	set opt O4
}
#
#set used project dir 
#
set prjdir E:/work_des00/Project/prj_10_hssdrc

set coredir $prjdir/core
set rtldir  $prjdir/rtl 
set tbdir   $prjdir/testbench 
set incdir  $prjdir/include 

if {$need_del} {
    vdel -all work
}

vlib work
# core codes 
vlog $coredir/mt48lc2m32b2.v
# headers codes 
# rtl codes          
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_data_path.v
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_data_path_p1.v
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_addr_path.v
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_addr_path_p1.v
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_mux.v
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_init_state.v
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_arbiter_out.v
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_access_manager.v
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_decoder_state.v
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_decoder.v
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_ba_map.v
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_arbiter_in.v
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_refr_counter.v
vlog -$opt -sv -lint -incr +incdir+$incdir+$rtldir $rtldir/hssdrc_top.v

# tb codes 
vlog -$opt -sv -lint +incdir+$incdir+$tbdir $tbdir/sdram_interpretator.sv

vlog -$opt -sv -lint +incdir+$incdir+$tbdir $tbdir/tb_prog.sv
vlog -$opt -sv -lint +incdir+$incdir+$tbdir $tbdir/tb_top.sv

if {$need_quit} {
    quit
}





