quit -sim

vlog C:/Xilinx/11.1/ISE/verilog/src/glbl.v
vlog ../lpm/mux2/lpm_mux2.v
vlog ../lpm/mux4/lpm_mux4.v
vlog ../lpm/mux8/lpm_mux8.v
vlog ./shiftr/shiftr.v
vlog ./shiftr_bram/shiftr_bram.v
vlog ./regfile/regfile.v
vlog ./alunit/alunit.v
vlog ./comparelogic/comparelogic.v
vlog ./checksum/checksum.v
vlog ./microcodelogic/microcodesrc/microcodesrc.v
vlog ./microcodelogic/microcodelogic.v
vlog ../lpm/stopar/lpm_stopar.v
vlog patlpp.v
vlog patlpp_tb.v

vsim -L unisims_ver -L unimacro_ver -voptargs=+acc patlpp_tb glbl

add wave -noupdate -divider {External Pins}
add wave -hex sim:/patlpp_tb/*
add wave -noupdate -divider {Checksum Unit}
add wave -hex sim:/patlpp_tb/thepp/checksum_inst/*
add wave -noupdate -divider {Comparer Internals}
add wave -hex sim:/patlpp_tb/thepp/comp_inst/*
add wave -noupdate -divider {Processor Internals}
add wave -hex sim:/patlpp_tb/thepp/*
add wave -noupdate -divider {Microcode Logic Internals}
add wave -hex sim:/patlpp_tb/thepp/mcodelogic_inst/*


run 3000ns
