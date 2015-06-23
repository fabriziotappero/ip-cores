all:
	verilator --trace -Wall -CFLAGS "-O3" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/sound/sound.v --exe main.cpp -I./../../../../rtl/soc/sound -I./../../../../rtl/common
	cd obj_dir && make -f Vsound.mk
