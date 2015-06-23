srcdir = ../src
testdir = ../test
commondir = ../../common
fpgadir = ../fpga
compressiondir = ../../compressionFunction/src
bdir = build/bdir
vdir = build/vdir
cdir = build/cdir
simdir = build/simdir
libbase = ../../lib/bsv
goldendir = ../../C_implementation/
plbdir = $(libbase)/PLBMaster/src
plbconfigdir = $(libbase)/PLBMaster/common
feederdir = $(libbase)/BRAMFeeder/src
plbemdir = $(libbase)/PLBMaster/test
bramdir = $(libbase)/BRAM
regmapdir = $(libbase)/RegisterMapper/src
regdir = $(libbase)/Register/src

compressiondir = ../../compressionFunction/src

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

md6_encode: $(testdir)/encodeBits.c  $(testdir)/encodeBits.h $(testdir)/md6_encode.c  $(goldendir)/md6_compress.c $(goldendir)/md6_mode.c $(goldendir)/md6.h
	gcc -g  -iquote$(goldendir) -I$(testdir) -o md6_encode $(testdir)/md6_encode.c $(testdir)/encodeBits.c $(goldendir)/md6_compress.c $(goldendir)/md6_mode.c

md6_random: $(testdir)/encodeBits.c  $(testdir)/encodeBits.h $(testdir)/md6_random.c  $(goldendir)/md6_compress.c $(goldendir)/md6_mode.c $(goldendir)/md6.h
	gcc -g -iquote$(goldendir) -I$(testdir)  -o md6_random $(testdir)/md6_random.c $(testdir)/encodeBits.c $(goldendir)/md6_compress.c $(goldendir)/md6_mode.c

md6_setbits: $(testdir)/encodeBits.c  $(testdir)/encodeBits.h $(testdir)/md6_setbits.c  $(goldendir)/md6_compress.c $(goldendir)/md6_mode.c $(goldendir)/md6.h
	gcc -g  -iquote$(goldendir) -I$(testdir) -o md6_setbits $(testdir)/md6_setbits.c $(testdir)/encodeBits.c $(goldendir)/md6_compress.c $(goldendir)/md6_mode.c


MD6Verify: md6_encode MD6TestBench
	perl $(testdir)/runtest.pl $(testdir)/benchmarks

MD6TestBench: build
	$(BSC) $(SIM_OPTS)  -D BIT64=0 -D PLB_DEFAULTS=0 -p +:$(srcdir):$(bdir):$(commondir):$(compressiondir):$(plbdir):$(plbconfigdir):$(feederdir):$(bramdir):$(compressiondir):$(plbemdir) -g mkMD6ControlTest $(testdir)/MD6ControlTest.bsv
	$(BSC) $(EXE_OPTS)  -D BIT64=0 -D PLB_DEFAULTS=0 -p +:$(srcdir):$(bdir):$(commondir):$(compressiondir):$(plbdir):$(plbconfigdir):$(feederdir):$(bramdir):$(compressiondir):$(plbemdir) -o MD6TestBench -e mkMD6ControlTest $(bdir)/mkMD6ControlTest.ba


MD6TestBench_fpga: build
	$(BSC) $(SIM_OPTS)  -D BIT64=0 -D PLB_DEFAULTS=0 -p +:$(srcdir):$(bdir):$(commondir):$(compressiondir):$(plbdir):$(plbconfigdir):$(feederdir):$(bramdir):$(compressiondir):$(plbemdir):$(regmapdir):$(regdir) -g mkMD6ControlEngineTest $(fpgadir)/MD6ControlEngineTest.bsv
	$(BSC) $(EXE_OPTS)  -D BIT64=0 -D PLB_DEFAULTS=0 -p +:$(srcdir):$(bdir):$(commondir):$(compressiondir):$(plbdir):$(plbconfigdir):$(feederdir):$(bramdir):$(compressiondir):$(plbemdir) -o MD6TestBench -e mkMD6ControlEngineTest $(bdir)/mkMD6ControlEngineTest.ba

MD6ControlEngine_fpga: build
	$(BSC) $(VER_OPTS) -D BIT64=0 -D PLB_DEFAULTS=0 -p +:$(fpgadir):$(srcdir):$(bdir):$(compressiondir):$(commondir):$(plbdir):$(plbconfigdir):$(feederdir):$(regmapdir):$(bramdir):$(regdir) -g mkMD6ControlEngine $(fpgadir)/MD6ControlEngine.bsv

clean: 
	rm -rf build