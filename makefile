###############################################################################
# Rules
###############################################################################
all:
	make -C or1k-sim
	./or1k-sim/or1knd-sim -f rtl/sim/test_image.bin
	make -C rtl/sim
	make -C rtl/sim_icarus

clean:
	make -C or1k-sim clean
	make -C rtl/sim clean
	make -C rtl/sim_icarus clean
