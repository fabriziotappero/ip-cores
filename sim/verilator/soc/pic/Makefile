all:
	verilator --trace -Wall -CFLAGS "-O3" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/pic/pic.v --exe main.cpp -I./../../../../rtl/soc/pic -I./../../../../rtl/common
	cd obj_dir && make -f Vpic.mk

main_plugin:
	verilator --trace -Wall -CFLAGS "-O3 -I./../../../../sim_pc" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/pic/pic.v --exe main_plugin.cpp -I./../../../../rtl/soc/pic -I./../../../../rtl/common
	cd obj_dir && make -f Vpic.mk
