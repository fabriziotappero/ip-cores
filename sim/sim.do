# This is the simulation script for Modelsim.
# 
# Instructions for running simulation
# 1. Launch Modelsim
# 2. Change directory to sim/
# 3. Type "do sim.do" from Modelsim prompt

vlib work
vmap work work
vlog +incdir+../src/verilog +incdir+../bench/verilog ../bench/verilog/aes_beh_model_decrypt_tb.sv
vsim aes_beh_model_decrypt_tb
run -all