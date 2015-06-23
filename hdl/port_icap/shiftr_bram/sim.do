quit -sim
vlog C:/Xilinx/11.1/ISE/verilog/src/glbl.v
vlog shiftr_bram.v
vlog shiftr_bram_tb.v

vsim -L unisims_ver -L unimacro_ver -voptargs=+acc shiftr_bram_tb glbl

add wave \
{sim:/shiftr_bram_tb/dut/en_in } \
{sim:/shiftr_bram_tb/dut/en_out } \
{sim:/shiftr_bram_tb/dut/clk } \
{sim:/shiftr_bram_tb/dut/rst } \
{sim:/shiftr_bram_tb/dut/empty } \
{sim:/shiftr_bram_tb/dut/data_in } \
{sim:/shiftr_bram_tb/dut/data_out }
run 10ns
