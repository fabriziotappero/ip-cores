vlib work

quit -sim
vlog gensrl.v
vlog shiftr.v
vlog shiftr_tb.v

vsim -L unisims_ver -voptargs=+acc shiftr_tb

add wave \
{sim:/shiftr_tb/dut/en_in } \
{sim:/shiftr_tb/dut/en_out } \
{sim:/shiftr_tb/dut/clk } \
{sim:/shiftr_tb/dut/rst } \
{sim:/shiftr_tb/dut/data_in } \
{sim:/shiftr_tb/dut/data_out } \
{sim:/shiftr_tb/dut/size } \
{sim:/shiftr_tb/dut/empty } 
run 10ns
