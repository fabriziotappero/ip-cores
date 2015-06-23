all:
	verilator --trace -Wall -CFLAGS "-O3 -I./../../../sim_pc" -LDFLAGS "-O3" --cc main.v --exe main.cpp -I./../../sim/sim_pc -I./../../../rtl/ao486 -I./../../../rtl/common -I./../../../rtl/soc/pc_bus -I./../../../rtl/ao486/memory -I./../../../rtl/ao486/pipeline -I./../../../rtl/ao486/common
	cd obj_dir && make -f Vmain.mk

main_plugin:
	verilator --trace -Wall -CFLAGS "-O3 -I./../../../sim_pc" -LDFLAGS "-O3" --cc main.v --exe main_plugin.cpp -I./../../sim/sim_pc -I./../../../rtl/ao486 -I./../../../rtl/common -I./../../../rtl/soc/pc_bus -I./../../../rtl/ao486/memory -I./../../../rtl/ao486/pipeline -I./../../../rtl/ao486/common
	cd obj_dir && make -f Vmain.mk

main_reader:
	verilator --trace -Wall -CFLAGS "-O3" -LDFLAGS "-O3" --cc main.v --exe main_reader.cpp -I./../../../rtl/ao486 -I./../../../rtl/common -I./../../../rtl/soc/pc_bus -I./../../../rtl/ao486/memory -I./../../../rtl/ao486/pipeline -I./../../../rtl/ao486/common
	cd obj_dir && make -f Vmain.mk
