all:
	verilator --trace -Wall -CFLAGS "-O3" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/pit/pit.v --exe main.cpp -I./../../../../rtl/soc/pit -I./../../../../rtl/common
	cd obj_dir && make -f Vpit.mk

main_plugin:
	verilator --trace -Wall -CFLAGS "-O3 -I./../../../../sim_pc" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/pit/pit.v --exe main_plugin.cpp -I./../../../../rtl/soc/pit -I./../../../../rtl/common
	cd obj_dir && make -f Vpit.mk
