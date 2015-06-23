cd ../run
vlib aes_decrypt256_tb_lib
vmap work aes_decrypt256_tb_lib
vlog +incdir+../../../rtl/verilog +incdir+../src  ../../../bench/verilog/aes_decrypt256_tb.sv
vsim aes_decrypt256_tb
#add wave *
run -all