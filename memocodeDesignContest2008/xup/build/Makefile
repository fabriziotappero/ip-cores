
#Copyright (c) 2008 MIT

#Permission is hereby granted, free of charge, to any person
#obtaining a copy of this software and associated documentation
#files (the "Software"), to deal in the Software without
#restriction, including without limitation the rights to use,
#copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the
#Software is furnished to do so, subject to the following
#conditions:

#The above copyright notice and this permission notice shall be
#included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#OTHER DEALINGS IN THE SOFTWARE.

#Author: Kermin Fleming

BSC_COMP = bsc

toplevel_module = mkTH

plbdir = ../PLBMaster
feederdir = ../../../lib/bsv/BRAMFeeder/src
debugdir = ../../../lib/bsv/Debug/
sortdir = ../../sort
ctrldir = ../../ctrl
commondir = ../Common
memo_common_dir = ../../common
aes_test = ../aesCore
aes_bsv_dir = ../../aesCore/bsv
aes_ver_dir = ../../aesCore/ver
bram_fifo_test = ../BRAMFIFO
sort_test = ../Sort
external_memory_dir = ../ExternalMemory
bramdir = ../../../lib/bsv/BRAM/
bram_target_dir      = ../../sort/BRAM_v
bram_fifo_dir = ../../sort/BRAMLevelFIFOAdders
top_dir = ../Top
bram_fifo_ver_dir = ../../sort/BRAM_v
rom_test = ../ROMTest

VER_OPTS =  +RTS -K100000000 --RTS -u -v -verilog -aggressive-conditions -vdir ./
SIM_OPTS =  +RTS -K100000000 --RTS -u -v -sim -aggressive-conditions -show-schedule 
EXE_OPTS =  +RTS -K100000000 --RTS -sim

#--------------------------------------------------------------------
# Build targets 
#--------------------------------------------------------------------

plbtester : 

	$(BSC_COMP) $(SIM_OPTS) -bdir ./ -p +:$(plbdir):$(bramdir):$(memo_common_dir):$(feederdir):$(bramdir):$(commondir):$(debugdir):$(bram_blue_target_dir) -g mkPLBMasterTester $(plbdir)/PLBMasterTester.bsv > out.log

plbtester_verilog : 
	$(BSC_COMP) $(VER_OPTS) -bdir ./ -p +:$(plbdir):$(bramdir):$(memo_common_dir):$(feederdir):$(bramdir):$(commondir):$(debugdir):$(bram_blue_target_dir) -g mkPLBMasterTester $(plbdir)/PLBMasterTester.bsv > out.log

external_memory_simulator:
	$(BSC_COMP) $(SIM_OPTS) -bdir ./ -p +:$(plbdir):$(commondir):$(memo_common_dir):$(external_memory_dir):$(bramdir):$(debugdir) \
	                       -g mkExternalMemoryTestbench $(external_memory_dir)/ExternalMemoryTestbench.bsv > out.log
	$(BSC_COMP) $(EXE_OPTS) -bdir ./ -e mkExternalMemoryTestbench  *.ba

external_memory_tester_verilog:
	$(BSC_COMP) $(VER_OPTS) -bdir ./ -p +:$(commondir):$(plbdir):$(feederdir):$(commondir):$(memo_common_dir):$(external_memory_dir):$(debugdir):$(bramdir):$(bram_blue_target_dir) -g mkExternalMemoryTester $(external_memory_dir)/ExternalMemoryTester.bsv > out.log

top_verilog:
	$(BSC_COMP) $(VER_OPTS) -dschedule  -D LogArrayLen=18 -bdir ./ -p +:$(plbdir):$(feederdir):$(commondir):$(memo_common_dir):$(external_memory_dir):$(debugdir):$(sortdir):$(ctrldir):$(aes_bsv_dir):$(bram_blue_target_dir):$(bram_fifo_ver_dir):$(bram_fifo_dir) -g mkSorter $(top_dir)/Sorter.bsv > out.log

aes_tester_verilog:
	$(BSC_COMP) $(VER_OPTS) -bdir ./ -p +:$(plbdir):$(feederdir):$(commondir):$(memo_common_dir):$(debugdir):$(external_memory_dir):$(sortdir):$(ctrldir):$(bramdir):$(aes_bsv_dir):$(debugdir):$(bram_blue_target_dir):$(bram_fifo_ver_dir):$(bram_fifo_dir) -g mkAESTester $(aes_test)/AESTester.bsv > out.log

bramfifo_tester_verilog:
	$(BSC_COMP) $(VER_OPTS) -bdir ./ -p +:$(plbdir):$(feederdir):$(commondir):$(memo_common_dir):$(external_memory_dir):$(sortdir):$(ctrldir):$(bramdir):$(bram_blue_target_dir):$(bram_fifo_ver_dir):$(bram_fifo_dir) -g mkBRAMFIFOTester $(bram_fifo_test)/BRAMFIFOTester.bsv > out.log

sort_tester_verilog:
	$(BSC_COMP) $(VER_OPTS) -bdir ./ -p +:$(plbdir):$(feederdir):$(commondir):$(memo_common_dir):$(debugdir):$(external_memory_dir):$(sortdir):$(ctrldir):$(bramdir):$(bram_blue_target_dir):$(bram_fifo_ver_dir):$(bram_fifo_dir) -g mkSortTester $(sort_test)/SortTester.bsv > out.log

rom_test_verilog:
	$(BSC_COMP) $(VER_OPTS) -bdir ./ -p +:$(plbdir):$(feederdir):$(commondir):$(memo_common_dir):$(debugdir):$(external_memory_dir):$(sortdir):$(ctrldir):$(bramdir):$(aes_bsv_dir):$(bram_blue_target_dir):$(bram_fifo_ver_dir):$(bram_fifo_dir):$(rom_test) -g mkROMTest $(rom_test)/ROMTest.bsv > out.log

#--------------------------------------------------------------------
# Default make target
#--------------------------------------------------------------------

all : plbtester

#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

clean :
	rm -rf $(junk) *~ \#* *.cxx *.ba *.o *.h *.bi *.bo *.bsv *.v *.log *.so a.out