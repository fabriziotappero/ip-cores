ECHO OFF

vlib work
vlib synthworks

vcom -work synthworks -2008 C:\work\vhdl2008c\RandomPkg_2_0\SortListPkg_int.vhd
vcom -work synthworks -2008 C:\work\vhdl2008c\RandomPkg_2_0\RandomBasePkg.vhd
vcom -work synthworks -2008 C:\work\vhdl2008c\RandomPkg_2_0\RandomPkg.vhd

vcom ../../source/tb_pkg_header.vhd ../../source/tb_pkg_body.vhd

vcom  -quiet -2008 vhdl/packet_gen.vhd

vcom -2008 -quiet vhdl/packet_gen_tb_ent.vhd vhdl/packet_gen_tb_bhv.vhd
vcom -quiet vhdl/packet_gen_ttb_ent.vhd vhdl/packet_gen_ttb_str.vhd
