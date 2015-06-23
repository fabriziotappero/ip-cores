srcdir = ../src
testdir = ../test
commondir = ../../common
fpgadir = ../fpga
bdir = build/bdir
vdir = build/vdir
cdir = build/cdir
simdir = build/simdir
libbase = ../../lib/bsv
goldendir = ../../C_implementation/
plbdir = $(libbase)/PLBMaster/src
plbconfigdir = $(libbase)/PLBMaster/common
feederdir = $(libbase)/BRAMFeeder/src
regdir = $(libbase)/Register/src
bramdir = $(libbase)/BRAM

BSC = bsc

VER_OPTS =  +RTS -K100000000 --RTS -u -v -verilog -aggressive-conditions -vdir $(vdir) -bdir $(bdir) 
SIM_OPTS =  +RTS -K100000000 --RTS -u -v -sim -aggressive-conditions -show-schedule -vdir $(vdir) -bdir $(bdir) 
EXE_OPTS =  +RTS -K100000000 --RTS -simdir $(simdir) -sim 
C_OPTS = -c -fPIC

#Synthesis params
mkdir = ../../toolflow
bsclib = ../../../../lib/bsclib
comp16top = mkCompressionFunction16
comp16srcs = $(vdir)/mkCompressionFunction16.v

build: 
	mkdir -p build
	mkdir -p $(bdir)
	mkdir -p $(vdir)
	mkdir -p $(cdir)
	mkdir -p $(simdir)

SimpleCompressionFunction_verilog: build
	$(BSC) $(VER_OPTS) -p +:$(srcdir):$(bdir):$(commondir) -g mkSimpleCompressionFunction1 $(srcdir)/CompressionFunction.bsv



SimpleCompressionFunctionTestbench64: build  $(cdir)/md6_compress64.o $(cdir)/CompressionFunctionTestbench64.o
	$(BSC) $(SIM_OPTS) -D BIT64=0 -p +:$(testdir):$(srcdir):$(bdir):$(commondir) -g mkCompressionFunctionTestbench $(testdir)/CompressionFunctionTestbench.bsv
	$(BSC) $(EXE_OPTS) -p +:$(testdir):$(srcdir):$(bdir):$(commondir) -e mkCompressionFunctionTestbench $(bdir)/mkCompressionFunctionTestbench.ba $(cdir)/CompressionFunctionTestbench64.o $(cdir)/md6_compress64.o

SimpleCompressionFunctionTestbench32: build $(cdir)/md6_compress32.o $(cdir)/CompressionFunctionTestbench32.o
	$(BSC) $(SIM_OPTS) -D BIT32=0 -p +:$(testdir):$(srcdir):$(bdir):$(commondir) -g mkCompressionFunctionTestbench $(testdir)/CompressionFunctionTestbench.bsv
	$(BSC) $(EXE_OPTS) -p +:$(testdir):$(srcdir):$(bdir):$(commondir) -e mkCompressionFunctionTestbench $(bdir)/mkCompressionFunctionTestbench.ba $(cdir)/CompressionFunctionTestbench32.o $(cdir)/md6_compress32.o

SimpleCompressionFunctionTestbench16: build $(cdir)/md6_compress16.o $(cdir)/CompressionFunctionTestbench16.o
	$(BSC) $(SIM_OPTS) -D BIT16=0 -p +:$(testdir):$(srcdir):$(bdir):$(commondir) -g mkCompressionFunctionTestbench $(testdir)/CompressionFunctionTestbench.bsv
	$(BSC) $(EXE_OPTS) -p +:$(testdir):$(srcdir):$(bdir):$(commondir) -e mkCompressionFunctionTestbench $(bdir)/mkCompressionFunctionTestbench.ba $(cdir)/CompressionFunctionTestbench16.o $(cdir)/md6_compress16.o

SimpleCompressionFunctionTestbench8: build $(cdir)/md6_compress8.o $(cdir)/CompressionFunctionTestbench8.o
	$(BSC) $(SIM_OPTS) -D BIT8=0 -p +:$(testdir):$(srcdir):$(bdir):$(commondir) -g mkCompressionFunctionTestbench $(testdir)/CompressionFunctionTestbench.bsv
	$(BSC) $(EXE_OPTS) -p +:$(testdir):$(srcdir):$(bdir):$(commondir) -e mkCompressionFunctionTestbench $(bdir)/mkCompressionFunctionTestbench.ba $(cdir)/CompressionFunctionTestbench8.o $(cdir)/md6_compress8.o




$(cdir)/md6_compress64.o: build $(goldendir)/md6_compress.c 
	gcc $(C_OPTS) -Dmd6_w=64 -Dmd6_n=89 -Dmd6_c=16 \
	-Dmd6_b=64 -Dmd6_v=1 -Dmd6_u=1 -Dmd6_k=8 -Dmd6_q=15 \
        -Dt0=17 -Dt1=18 -Dt2=21 -Dt3=31 -Dt4=67 -Dt5=89 \
	-iquote$(goldendir) -o$(cdir)/md6_compress64.o $(goldendir)/md6_compress.c 

$(cdir)/md6_compress32.o: build $(goldendir)/md6_compress.c 
	gcc $(C_OPTS) -Dmd6_w=32 -Dmd6_n=178 -Dmd6_c=32 \
	-Dmd6_b=128 -Dmd6_v=2 -Dmd6_u=2 -Dmd6_k=16 -Dmd6_q=30 \
        -Dt0=33 -Dt1=35 -Dt2=49 -Dt3=53 -Dt4=111 -Dt5=178 \
	-iquote$(goldendir) -o$(cdir)/md6_compress32.o $(goldendir)/md6_compress.c 

$(cdir)/md6_compress16.o: build $(goldendir)/md6_compress.c 
	gcc $(C_OPTS) -iquote$(goldendir) -o$(cdir)/md6_compress16.o $(goldendir)/md6_compress.c 

$(cdir)/md6_compress8.o: build $(goldendir)/md6_compress.c 
	gcc $(C_OPTS) -quote$(goldendir) -o$(cdir)/md6_compress8.o $(goldendir)/md6_compress.c 



$(cdir)/CompressionFunctionTestbench64.o: build $(testdir)/CompressionFunctionTestbench.c
	gcc $(C_OPTS) -Dmd6_w=64 -Dmd6_n=89 -Dmd6_c=16 \
	-Dmd6_b=64 -Dmd6_v=1 -Dmd6_u=1 -Dmd6_k=8 -Dmd6_q=15 \
        -Dt0=17 -Dt1=18 -Dt2=21 -Dt3=31 -Dt4=67 -Dt5=89 \
	-iquote$(goldendir) -o$(cdir)/CompressionFunctionTestbench64.o $(testdir)/CompressionFunctionTestbench.c


$(cdir)/CompressionFunctionTestbench32.o: build $(testdir)/CompressionFunctionTestbench.c
	gcc $(C_OPTS) -Dmd6_w=32 -Dmd6_n=178 -Dmd6_c=32 \
	-Dmd6_b=128 -Dmd6_v=2 -Dmd6_u=2 -Dmd6_k=16 -Dmd6_q=30 \
	-Dt0=33 -Dt1=35 -Dt2=49 -Dt3=53 -Dt4=111 -Dt5=178 \
	-iquote$(goldendir) -o$(cdir)/CompressionFunctionTestbench32.o $(testdir)/CompressionFunctionTestbench.c

$(cdir)/CompressionFunctionTestbench16.o: build $(testdir)/CompressionFunctionTestbench.c
	gcc $(C_OPTS) -iquote$(goldendir) -o$(cdir)/CompressionFunctionTestbench16.o $(testdir)/CompressionFunctionTestbench.c	
$(cdir)/CompressionFunctionTestbench8.o: build $(testdir)/CompressionFunctionTestbench.c
	gcc $(C_OPTS) -iquote$(goldendir) -o$(cdir)/CompressionFunctionTestbench8.o $(testdir)/CompressionFunctionTestbench.c	

MD6Engine_fpga: build
	$(BSC) $(VER_OPTS) -D BIT64=0 -D PLB_DEFAULTS=0 -p +:$(fpgadir):$(srcdir):$(bdir):$(commondir):$(plbdir):$(plbconfigdir):$(feederdir):$(bramdir) -g mkMD6Engine $(fpgadir)/MD6Engine.bsv

MD6_comp16_toolflow90:  MD6Engine_fpga
	make -f $(mkdir)/rc.mk "synthdir=${mkdir}" "toplevel=${comp16top}" "bscdir = ${vdir}" "vsrcs=${comp16srcs}" "libdir=${bsclib}"
	make -f $(mkdir)/par90.mk "synthdir=${mkdir}" "vsrcs=syn-current/synthesized.v" "toplevel=${verilogtop}"



clean:
	rm -rf build