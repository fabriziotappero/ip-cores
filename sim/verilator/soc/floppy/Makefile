all:
	verilator --trace -Wall -CFLAGS "-O3" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/floppy/floppy.v --exe main.cpp -I./../../../../rtl/common
	cd obj_dir && make -f Vfloppy.mk

main_plugin:
	verilator --trace -Wall -CFLAGS "-O3 -I./../../../../sim_pc" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/floppy/floppy.v --exe main_plugin.cpp -I./../../../../rtl/soc/floppy -I./../../../../rtl/common
	cd obj_dir && make -f Vfloppy.mk
