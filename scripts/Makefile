ifeq ($(VCD), 1)
ICARUS_OPTIONS += -DVCD
endif
rtl-tests:
	mkdir -p ../build/sim
	mkdir -p ../log
	iverilog -stb_instantiations -cicarus.scr $(ICARUS_OPTIONS) -o ../build/sim/l2_switch.elf
	vvp ../build/sim/l2_switch.elf

