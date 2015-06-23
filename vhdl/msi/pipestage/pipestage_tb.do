vcom -work work -2002 -explicit d:/lib/vhdl/tb/clk_rst/clk_rst.vhd
vcom -work work -2002 -explicit d:/lib/vhdl/msi/pipestage/pipestage.vhd
vcom -work work -2002 -explicit d:/lib/vhdl/msi/pipestage/pipestage_tb.vhd
vsim pipestage_tb
log -r /*
do pipestage_tb_wave.do
run 220 ns

