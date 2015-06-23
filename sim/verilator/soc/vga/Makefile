all:
	verilator --trace -Wall -CFLAGS "-O3" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/vga/vga.v --exe main.cpp -I./../../../../rtl/soc/vga -I./../../../../rtl/common
	cd obj_dir && make -f Vvga.mk

main_plugin:
	verilator --trace -Wall -CFLAGS "-O3 -I./../../../../sim_pc" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/vga/vga.v --exe main_plugin.cpp -I./../../../../rtl/soc/vga -I./../../../../rtl/common
	cd obj_dir && make -f Vvga.mk
