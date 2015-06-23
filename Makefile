
VV         = vcs
VVOPTS     = -o $@ +v2k +vc -sverilog -timescale=1ns/1ps +vcs+lic+wait +multisource_int_delays +neg_tchk +libext+.v+.vlib+.vh 

TESTBENCH_SOURCE = scan_testbench.v scan.v

all: run_test

%.v: %.perl.v deperlify.pl scan_signal_list.pl
	perl deperlify.pl $*.perl.v

testbench.exe: $(TESTBENCH_SOURCE)
	$(VV) $(VVOPTS) $(TESTBENCH_SOURCE) | tee $@.log

run_test: testbench.exe
	./testbench.exe

