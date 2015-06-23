all:
	verilator --trace -Wall -CFLAGS "-O3" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/pc_dma/pc_dma.v --exe main.cpp -I./../../../../rtl/soc/pc_dma -I./../../../../rtl/common
	cd obj_dir && make -f Vpc_dma.mk

main_plugin:
	verilator --trace -Wall -CFLAGS "-O3 -I./../../../../sim_pc" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/pc_dma/pc_dma.v --exe main_plugin.cpp -I./../../../../rtl/soc/pc_dma -I./../../../../rtl/common
	cd obj_dir && make -f Vpc_dma.mk
