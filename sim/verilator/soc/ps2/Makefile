all:
	verilator --trace -Wall -CFLAGS "-O3" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/ps2/ps2.v --exe main.cpp -I./../../../../rtl/soc/ps2 -I./../../../../rtl/common
	cd obj_dir && make -f Vps2.mk

main_plugin:
	verilator --trace -Wall -CFLAGS "-O3 -I./../../../../sim_pc" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/ps2/ps2.v --exe main_plugin.cpp -I./../../../../rtl/soc/ps2 -I./../../../../rtl/common
	cd obj_dir && make -f Vps2.mk
