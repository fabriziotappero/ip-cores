# hardware
vlog -work work +incdir+C:/Users/jeffA/Desktop/rtl/sport/trunk/rtl/verilog C:/Users/jeffA/Desktop/rtl/sport/trunk/rtl/verilog/wb_interface.v
vlog -work work +incdir+C:/Users/jeffA/Desktop/rtl/sport/trunk/rtl/verilog C:/Users/jeffA/Desktop/rtl/sport/trunk/rtl/verilog/fifos.v
vlog -work work +incdir+C:/Users/jeffA/Desktop/rtl/sport/trunk/rtl/verilog C:/Users/jeffA/Desktop/rtl/sport/trunk/rtl/verilog/sport_top.v

# testbench stuff
vlog -work work +incdir+C:/Users/jeffA/Desktop/rtl/sport/trunk/rtl/verilog +incdir+C:/Users/jeffA/Desktop/rtl/sport/trunk/bench C:/Users/jeffA/Desktop/rtl/sport/trunk/bench/testbench_top.v
vlog -work work +incdir+C:/Users/jeffA/Desktop/rtl/sport/trunk/bench +incdir+C:/Users/jeffA/Desktop/rtl/sport/trunk/rtl/verilog C:/Users/jeffA/Desktop/rtl/sport/trunk/bench/testcase_1.v
