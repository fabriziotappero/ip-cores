BSC_COMP = bsc
VER_OPTS =  +RTS -K100000000 --RTS -u -verilog -elab -no-show-method-conf \
	-aggressive-conditions -vdir ./build/vdir -bdir ./build/bdir -dschedule
SIM_OPTS =  +RTS -K100000000 --RTS -u -verilog -aggressive-conditions -dschedule -vdir ./build/vdir -bdir ./build/bdir
EXE_OPTS =  +RTS -K100000000 --RTS -verilog -vsim iverilog -vdir ./build/vdir -bdir ./build/bdir
SIM_OPTS_NEW =  +RTS -K100000000 --RTS -u -sim -aggressive-conditions -dschedule -vdir ./build/vdir -bdir ./build/bdir

sortdir = .
commondir = ../common
bsv_sim = ./BRAM_v
bsv_ver = ./BRAM_v
level_fifo_addr = ./BRAMLevelFIFOAdders
level_fifo_muxes = ./BRAMLevelFIFOMuxes

bram_fifo_testbench: 
	mkdir -p build
	mkdir -p build/bdir
	mkdir -p build/vdir
	cp $(level_fifo_addr)/zeros.data ./
	$(BSC_COMP) $(SIM_OPTS) -show-schedule -p +:$(bsv_sim):./:$(commondir):$(level_fifo_addr):./build/bdir -g mkVLevelFIFOTester $(sortdir)/VLevelFIFOTester.bsv > out.log
	$(BSC_COMP) $(EXE_OPTS) -e mkVLevelFIFOTester ./build/vdir/*.v $(bsv_sim)/*.v

bram_fifo_testbench_full: 
	mkdir -p build
	mkdir -p build/bdir
	mkdir -p build/vdir
	cp $(level_fifo_addr)/zeros.data ./
	$(BSC_COMP) $(SIM_OPTS) -show-schedule -p +:./:$(bsv_sim):$(commondir):$(level_fifo_addr):./build/bdir -g mkVLevelFIFOTesterFull $(sortdir)/VLevelFIFOTester.bsv > out.log
	$(BSC_COMP) $(EXE_OPTS) -e mkVLevelFIFOTesterFull ./build/vdir/*.v $(bsv_sim)/*.v

sort_tree_perf_testbench: 
	mkdir -p build
	mkdir -p build/bdir
	mkdir -p build/vdir
	$(BSC_COMP) $(SIM_OPTS) -show-schedule -p +:./:$(commondir):$(bsv_sim):$(level_fifo_addr):./build/bdir -g mkSortTreeTestbench $(sortdir)/SortTreeTestbench.bsv > out.log
	$(BSC_COMP) $(EXE_OPTS) -e mkSortTreeTestbench ./build/vdir/*.v $(bsv_sim)/*.v

sort_tree_adder_verilog: clean 
	mkdir -p build
	mkdir -p build/bdir
	mkdir -p build/vdir
	$(BSC_COMP) $(VER_OPTS) -p +:$(bsv_ver):$(level_fifo_addr):./:$(commondir):./build/bdir -g mkBRAMLevel6MergerInstance $(sortdir)/Sort.bsv > out.log

sort_tree_128_verilog: clean 
	mkdir -p build
	mkdir -p build/bdir
	mkdir -p build/vdir
	$(BSC_COMP) $(VER_OPTS) -p +:$(bsv_ver):$(level_fifo_addr):./:$(commondir):./build/bdir -g mkSortTree128 $(sortdir)/SortTree128.bsv > out.log

sort_tree_256_verilog: clean 
	mkdir -p build
	mkdir -p build/bdir
	mkdir -p build/vdir
	$(BSC_COMP) $(VER_OPTS) -p +:$(bsv_ver):$(level_fifo_addr):./:$(commondir):./build/bdir -g mkSortTree256 $(sortdir)/SortTree256.bsv > out.log

sort_tree_mux_verilog: clean 
	mkdir -p build
	mkdir -p build/bdir
	mkdir -p build/vdir
	$(BSC_COMP) $(VER_OPTS) -p +:$(bsv_ver):./:$(commondir):$(level_fifo_muxes):./build/bdir -g mkBRAMLevel6MergerInstance $(sortdir)/Sort.bsv > out.log

butter_tb:
	mkdir -p build
	mkdir -p build/bdir
	mkdir -p build/vdir
	$(BSC_COMP) $(VER_OPTS) -p +:$(bsv_ver):./:$(commondir):$(level_fifo_muxes):./build/bdir -g mkButterflySortTest $(sortdir)/ButterflySort.bsv > out.log
	$(BSC_COMP) $(EXE_OPTS) -e mkButterflySortTest ./build/vdir/*.v $(bsv_sim)/*.v	

%:
	mkdir -p build
	mkdir -p build/bdir
	mkdir -p build/vdir
	$(BSC_COMP) $(VER_OPTS) -show-schedule -p +:$(bsv_sim):$(level_fifo_addr):./:$(commondir):./build/bdir $@.bsv


bram_fifo_test: 
	mkdir -p build
	mkdir -p build/bdir
	mkdir -p build/vdir
	$(BSC_COMP) $(SIM_OPTS) -show-schedule -p +:./:$(commondir):$(bsv_sim):$(level_fifo_addr):./build/bdir -g mkBRAMFIFOTest $(sortdir)/BRAMFIFOTest.bsv > out.log
	$(BSC_COMP) $(EXE_OPTS) -e mkBRAMFIFOTest ./build/vdir/*.v $(bsv_sim)/*.v

sort_tree_test: 
	mkdir -p build
	mkdir -p build/bdir
	mkdir -p build/vdir
	$(BSC_COMP) $(SIM_OPTS) -show-schedule -p +:./:$(commondir):$(bsv_sim):$(level_fifo_addr):./build/bdir -g mkSortTest $(sortdir)/SortTest.bsv > out.log
	$(BSC_COMP) $(EXE_OPTS) -e mkSortTest ./build/vdir/*.v $(bsv_sim)/*.v

.PHONY: clean

clean:
	rm -rf build
