# common files for both modules
vlog -work work +incdir+C:/Users/jeffA/Desktop/rtl/wiegand/trunk/rtl/verilog C:/Users/jeffA/Desktop/rtl/wiegand/trunk/rtl/verilog/wb_interface.v
vlog -work work +incdir+C:/Users/jeffA/Desktop/rtl/wiegand/trunk/rtl/verilog C:/Users/jeffA/Desktop/rtl/wiegand/trunk/rtl/verilog/fifos.v

# uncomment to compile Wiegand TX
vlog -work work +incdir+C:/Users/jeffA/Desktop/rtl/wiegand/trunk/rtl/verilog C:/Users/jeffA/Desktop/rtl/wiegand/trunk/rtl/verilog/wiegand_tx_top.v

# uncomment to compile Wiegand RX
vlog -work work +incdir+C:/Users/jeffA/Desktop/rtl/wiegand/trunk/rtl/verilog C:/Users/jeffA/Desktop/rtl/wiegand/trunk/rtl/verilog/wiegand_rx_top.v

# testbench stuff
vlog -work work +incdir+C:/Users/jeffA/Desktop/rtl/wiegand/trunk/rtl/verilog C:/Users/jeffA/Desktop/rtl/wiegand/trunk/bench/testbench_top.v
vlog -work work +incdir+C:/Users/jeffA/Desktop/rtl/wiegand/trunk/bench +incdir+C:/Users/jeffA/Desktop/rtl/wiegand/trunk/rtl/verilog C:/Users/jeffA/Desktop/rtl/wiegand/trunk/bench/testcase_1.v
