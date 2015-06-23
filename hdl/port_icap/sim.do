quit -sim

vlog C:/Xilinx/11.1/ISE/verilog/src/glbl.v
vcom ../ICAP_VIRTEX4test/proc_common_pkg.vhd
vcom ../ICAP_VIRTEX4test/family_support.vhd
vcom ../ICAP_VIRTEX4test/muxf_struct_f.vhd
vcom ../ICAP_VIRTEX4test/cntr_incr_decr_addn_f.vhd
vcom ../ICAP_VIRTEX4test/dynshreg_f.vhd
vcom ../ICAP_VIRTEX4test/srl_fifo_rbu_f.vhd
vcom ../ICAP_VIRTEX4test/srl_fifo_f.vhd
vcom ../ICAP_VIRTEX4test/ICAP_VIRTEX4test.vhd
vlog ../PATLPP/shiftr_bram/shiftr_bram.v
vlog ./port_icap_buf.v
vlog ./port_icap_tb.v

vsim -L unisims_ver -L unimacro_ver -voptargs=+acc port_icap_tb glbl

add wave -hex /port_icap_tb/*
add wave -hex /port_icap_tb/DUT/*

run 400ns

