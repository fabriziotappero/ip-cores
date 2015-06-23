# This is for simulating the encryption model with Modelsim.
# 
# Instructions for running simulation
# 1. Launch Modelsim
# 2. Change directory to sim/
# 3. Type "do sim_enc.do" from Modelsim prompt

vlib work
vmap work work
vlog +incdir+../src/verilog +incdir+../bench/verilog ../bench/verilog/aes_beh_model_encrypt_tb.sv
vsim aes_beh_model_encrypt_tb
run -all