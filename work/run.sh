g++ -c  -fpic ../pli/env_aes.c  -std=c++11 -Wwrite-strings -fpermissive
g++ -shared  -o env_aes.vpi env_aes.o -lvpi -std=c++11 -Wwrite-strings -fpermissive
iverilog -oenv_aes.vvp  ../testbench/aes_tb_vpi.v ../rtl/*.v 
vvp -M. -menv_aes env_aes.vvp
