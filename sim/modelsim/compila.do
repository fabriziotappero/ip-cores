vlib work
vcom -93 ../../rtl/riscompatible_package.vhd
vcom -93 ../../rtl/reg.vhd
vcom -93 ../../rtl/select_and_control.vhd
vcom -93 ../../rtl/ud_package.vhd
vcom -93 ../../rtl/ud.vhd
vcom -93 ../../rtl/ula.vhd
vcom -93 ../../rtl/memory.vhd
vcom -93 ../../rtl/gpio.vhd
vcom -93 ../../rtl/registerbank.vhd
vcom -93 ../../rtl/riscompatible_core.vhd
vcom -93 ../../rtl/riscompatible.vhd
vcom -93 ../../bench/riscompatible_tb.vhd
vsim riscompatible_tb
do wave_riscompatible.do
run 100 us

