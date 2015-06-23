cd ../run
vlib aes_decrypt128_tb_lib
vmap work aes_decrypt128_tb_lib
vlog +incdir+../../../rtl/verilog +incdir+../src  ../../../bench/verilog/aes_decrypt128_tb.sv
vsim aes_decrypt128_tb
#add wave *
run -all