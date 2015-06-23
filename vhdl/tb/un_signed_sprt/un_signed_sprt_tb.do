vcom -work work -2002 -explicit -novopt //VBOXSVR/d/lib/vhdl/tb/un_signed_sprt/un_signed_sprt.vhd
vcom -work work -2002 -explicit -novopt //VBOXSVR/d/lib/vhdl/tb/un_signed_sprt/un_signed_sprt_tb.vhd
vsim -voptargs="+acc" un_signed_sprt_tb
run 
