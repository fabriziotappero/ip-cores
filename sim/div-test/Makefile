all:
	verilator --trace -Wall -CFLAGS "-O3" -LDFLAGS "-O3" --cc main.v --exe main.cpp
	cd obj_dir && make -f Vmain.mk
