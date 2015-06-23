/*
Copyright (c) 2008 MIT

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Author: Kermin Fleming
*/
BSC_COMP = bsc

VER_OPTS =  +RTS -K100000000 --RTS -u -v  -verilog \
	    -aggressive-conditions -vdir ./
srcdir = ..
commondir = ../../../common

v_dir  = ../../verilog/rtl/verilog
coregen_dir = ../../verilog/rtl/coregen/aesDataFifo
corelib_dir = ../../../common/verilog/src/XilinxCoreLib
prim_dir =  ../../../common/verilog/src/uni9000/
unisim_dir =  ../../../common/verilog/src/unisims/
sim_base = ../../../common/verilog/
pipeline_dir = ../../../aesCorePipelined

BSV_SRCS = $(srcdir)/aesCipherTop.bsv

V_SRCS = $(v_dir)/aes_sbox.v           \
	 $(v_dir)/aes_key_expand_128.v \
	 $(v_dir)/aes_cipher_top.v


C_SRCS = $(srcdir)/aes_core.c         \
	 $(srcdir)/reference_cipher.c \
	 $(srcdir)/aes_core.h 

standalone : $(C_SRCS)
	gcc -I.. -DEXECUTABLE -o aes.exe $(C_SRCS) 


reference_cypher.o : $(C_SRCS)
	gcc -c -I.. $(C_SRCS)


mkTH.v : $(BSV_SRCS)
	$(BSC_COMP) $(VER_OPTS) -bdir . -vdir . -p +:$(srcdir):$(commondir):$(pipeline_dir) -g \
	mkTH $(srcdir)/aesCipherTop.bsv > bsc.log

mkTH_single.v : $(BSV_SRCS)
	$(BSC_COMP) $(VER_OPTS) -bdir . -vdir . -p +:$(srcdir):$(commondir) -g \
	mkTH_single $(srcdir)/aesCipherTop.bsv > bsc.log

mkTH : mkTH.v $(V_SRCS) standalone
	cp $(v_dir)/*.v .
	cp $(v_dir)/aes_sbox.dat ./
	cp $(coregen_dir)/*.mif ./
	./aes.exe
	vcs +v2k -Mupdate -o simv +libext+.v+ -y $(BLUESPECDIR)/Verilog ./ -y . -y $(BLUESPECDIR)/Prelude -y $(BLUESPECDIR)/Libraries -y ../../verilog/rtl/verilog -y ../../../common -y ./ -y ../../verilog/rtl/coregen/aesDataFifo -y ../../../common/verilog/src/XilinxCoreLib +incdir+../../../common/verilog/src/uni9000/  -y ../../../common/verilog/src/unisims/ -y ../../../aesCorePipelined -y ../../../common/verilog/  main.v mkTH.v  ../../verilog/rtl/coregen/aesDataFifo/aesCommandFIFO.v


	#$(BSC_COMP) $(VER_OPTS) -vsim iverilog -p \
	#+:$(v_dir):$(commondir):$(coregen_dir):$(corelib_dir):$(prim_dir):$(unisim_dir):$(sim_base) -e mkTH *.v 


mkTH_iverilog : mkTH.v $(V_SRCS) standalone
	cp $(v_dir)/*.v .
	cp $(v_dir)/aes_sbox.dat ./
	cp $(coregen_dir)/*.mif ./
	./aes.exe
	$(BSC_COMP) $(VER_OPTS) -vsim iverilog -p \
	+:$(v_dir):$(commondir):$(coregen_dir):$(pipeline_dir):$(corelib_dir):$(prim_dir):$(unisim_dir):$(sim_base):$(pipeline_dir) -e mkTH mkTH.v aes_sbox.v
 
mkTH_single : mkTH_single.v $(V_SRCS) standalone
	cp $(v_dir)/*.v .
	cp $(v_dir)/aes_sbox.dat ./
	cp $(coregen_dir)/*.mif ./
	./aes.exe
	$(BSC_COMP) $(VER_OPTS) -vsim iverilog -p \
	+:$(v_dir):$(commondir):$(coregen_dir):$(corelib_dir):$(prim_dir):$(unisim_dir) -e mkTH_single mkTH_single.v



clean:
	rm -f a.out *~ *.o *.bi *.v *.log *.bo


