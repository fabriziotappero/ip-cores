all:
	verilator --trace -Wall -CFLAGS "-O3" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/hdd/hdd.v --exe main.cpp -I./../../../../rtl/soc/hdd -I./../../../../rtl/common
	cd obj_dir && make -f Vhdd.mk

main_plugin:
	verilator --trace -Wall -CFLAGS "-O3 -I./../../../../sim_pc" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/hdd/hdd.v --exe main_plugin.cpp -I./../../../../rtl/soc/hdd -I./../../../../rtl/common
	cd obj_dir && make -f Vhdd.mk
