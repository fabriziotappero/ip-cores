cd ../run
vlib aes_decrypt192_tb_lib
vmap work aes_decrypt192_tb_lib
vlog +incdir+../../../rtl/verilog +incdir+../src  ../../../bench/verilog/aes_decrypt192_tb.sv
vsim aes_decrypt192_tb
#add wave *
run -all