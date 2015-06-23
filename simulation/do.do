vlib work

vlog *.v
vlog ../rtl/*.v


vsim -novopt RS_dec_tb


do wave.do



 
run -a
