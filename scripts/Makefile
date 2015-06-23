ifeq ($(VCD), 1)
ICARUS_OPTIONS += -DVCD
endif
rtl-tests:
	mkdir -p ../build/sim
	mkdir -p ../log
	iverilog -stb_ethernet -cicarus.scr $(ICARUS_OPTIONS) -o ../build/sim/ethmac.elf
	vvp ../build/sim/ethmac.elf

