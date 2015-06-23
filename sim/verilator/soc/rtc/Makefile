all:
	verilator --trace -Wall -CFLAGS "-O3" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/rtc/rtc.v --exe main.cpp -I./../../../../rtl/common
	cd obj_dir && make -f Vrtc.mk

main_plugin:
	verilator --trace -Wall -CFLAGS "-O3 -I./../../../../sim_pc" -LDFLAGS "-O3" --cc ./../../../../rtl/soc/rtc/rtc.v --exe main_plugin.cpp -I./../../../../rtl/soc/rtc -I./../../../../rtl/common
	cd obj_dir && make -f Vrtc.mk
