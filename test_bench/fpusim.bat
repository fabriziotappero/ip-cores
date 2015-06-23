set REL= ..\

vlib work

vcom %REL%fpupack.vhd
vcom %REL%pre_norm_addsub.vhd
vcom %REL%addsub_28.vhd
vcom %REL%post_norm_addsub.vhd
vcom %REL%pre_norm_mul.vhd
vcom %REL%mul_24.vhd
vcom %REL%serial_mul.vhd
vcom %REL%post_norm_mul.vhd
vcom %REL%pre_norm_div.vhd
vcom %REL%serial_div.vhd
vcom %REL%post_norm_div.vhd
vcom %REL%pre_norm_sqrt.vhd
vcom %REL%sqrt.vhd
vcom %REL%post_norm_sqrt.vhd
vcom %REL%comppack.vhd
vcom %REL%fpu.vhd

vcom txt_util.vhd
vcom tb_fpu.vhd

pause Start simulation?

vsim -do fpu_wave.do tb_fpu


