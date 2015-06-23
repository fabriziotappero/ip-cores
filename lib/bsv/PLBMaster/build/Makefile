#/*
#Copyright (c) 2008 MIT
#
#Permission is hereby granted, free of charge, to any person
#obtaining a copy of this software and associated documentation
#files (the "Software"), to deal in the Software without
#restriction, including without limitation the rights to use,
#copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the
#Software is furnished to do so, subject to the following
#conditions:
#
#The above copyright notice and this permission notice shall be
#included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#OTHER DEALINGS IN THE SOFTWARE.
#
#Author: Kermin Fleming
#*/
 
srcdir = ../src
debugdir = ../../Debug
testdir = ../test
commondir = ../common
bramdir = ../../BRAM/
feederdir = ../../BRAMFeeder/src
fpgadir = ../fpga
bdir = build/bdir
vdir = build/vdir
cdir = build/cdir
simdir = build/simdir

BSC = bsc

VER_OPTS =  +RTS -K100000000 --RTS -u -v -verilog -aggressive-conditions -vdir ./
SIM_OPTS =  +RTS -K100000000 --RTS -u -v -sim -aggressive-conditions -show-schedule 
EXE_OPTS =  +RTS -K100000000 --RTS -sim

#--------------------------------------------------------------------
# Build targets 
#--------------------------------------------------------------------

build:
	mkdir -p build
	mkdir -p $(bdir)
	mkdir -p $(vdir)
	mkdir -p $(cdir)
	mkdir -p $(simdir)

plbmaster : build
	$(BSC) $(VER_OPTS) -D PLB_DEFAULTS=0  -bdir $(bdir) -vdir $(vdir) -p +:$(srcdir):$(bramdir):$(debugdir):$(commondir):$(feederdir):$(bdir) -g mkPLBMaster $(srcdir)/PLBMaster.bsv > out.log

plbtester_verilog : build 
	$(BSC) $(VER_OPTS) -D PLB_DEFAULTS=0 -bdir $(bdir) -vdir $(vdir) -p +:$(srcdir):$(bramdir):$(debugdir):$(commondir):$(feederdir):$(bdir):$(fpgadir) -g mkPLBMasterTester $(fpgadir)/PLBMasterTester.bsv > out.log

clean :
	rm -rf build