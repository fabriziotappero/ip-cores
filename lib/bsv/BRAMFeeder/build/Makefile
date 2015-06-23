srcdir = ../src
debugdir = ../../Debug
testdir = ../test
commondir = ../../common
bramdir = ../../BRAM/
bdir = build/bdir
vdir = build/vdir
cdir = build/cdir
simdir = build/simdir

BSC = bsc

VER_OPTS =  +RTS -K100000000 --RTS -u -v -verilog -aggressive-conditions -vdir $(vdir) -bdir $(bdir) 
SIM_OPTS =  +RTS -K100000000 --RTS -u -v -sim -aggressive-conditions -show-schedule -vdir $(vdir) -bdir $(bdir) 
EXE_OPTS =  +RTS -K100000000 --RTS -simdir $(simdir) -sim 
C_OPTS = -c -fPIC

build: 
	mkdir -p build
	mkdir -p $(bdir)
	mkdir -p $(vdir)
	mkdir -p $(cdir)
	mkdir -p $(simdir)

BRAMFeeder: build
	$(BSC) $(VER_OPTS) -p +:$(testdir):$(srcdir):$(bdir):$(bramdir):$(debugdir) -g mkBRAMFeeder $(srcdir)/BRAMFeeder.bsv


clean:
	rm -rf build

.PHONY: build