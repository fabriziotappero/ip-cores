vcom -work work -2002 -explicit D:/lib/vhdl/tb/clk_rst/clk_rst.vhd
vcom -work work -2002 -explicit D:/lib/vhdl/msi/pipestage/pipestage.vhd
vcom -work work -2002 -explicit D:/lib/vhdl/arith/sincos/sincos.vhd
vcom -work work -2002 -explicit D:/lib/vhdl/arith/sincos/sincos_tb.vhd
vsim work.sincos_tb
log -r /*
do sincos_tb_wave.do
run 2800 ns

