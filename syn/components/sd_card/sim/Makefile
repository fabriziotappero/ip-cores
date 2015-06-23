all:
	verilator --trace -Wall -CFLAGS "-O3" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/driver_sd/driver_sd.v --exe main.cpp -I./../../../../rtl/soc/driver_sd/
	cd obj_dir && make -f Vdriver_sd.mk
