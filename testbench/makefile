%_tb: %_tb.v
	iverilog -o $@.vo $< ../rtl/*.v
	vvp $@.vo

all: gost89_pipelined_ecb_tb gost89_ecb_tb gost89_cfb_tb gost89_mac_tb

clean:
	rm -f *.vo *.vcd

.DEFAULT_GOAL := all

