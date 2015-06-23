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
fpgadir = ../fpga
registermapperdir = ../../RegisterMapper/src
registerdir = ../../Register/src
cbusdir = ../../CBusUtils
fifoutilsdir = ../../FIFOUtility
clientserverdir = ../../ClientServerUtils
bdir = build/bdir
vdir = build/vdir
cdir = build/cdir
simdir = build/simdir

BSC = bsc

VER_OPTS =  +RTS -K100000000 --RTS -u -v -verilog -aggressive-conditions  -vdir $(vdir) -bdir $(bdir)
SIM_OPTS =  +RTS -K100000000 --RTS -u -v -sim -aggressive-conditions -show-schedule  --keep-fires -vdir $(vdir) -bdir $(bdir)
EXE_OPTS =  +RTS -K100000000 --RTS -u  -simdir $(simdir) -sim

#--------------------------------------------------------------------
# Build targets 
#--------------------------------------------------------------------

build:
	mkdir -p build
	mkdir -p $(bdir)
	mkdir -p $(vdir)
	mkdir -p $(cdir)
	mkdir -p $(simdir)

.PHONY: spitester

spitester : build
	$(BSC) $(SIM_OPTS) -p +:$(srcdir):$(fifoutilsdir):$(debugdir):$(bdir):$(registermapperdir):$(registerdir):$(fpgadir) -g mkSPITester $(testdir)/SPITester.bsv > out.log
	$(BSC) $(EXE_OPTS) -o spitester -p +:$(srcdir):$(fifoutilsdir):$(debugdir):$(bdir):$(registermapperdir):$(fpgadir):$(registerdir) -e mkSPITester $(bdir)/mkSPITester.ba > out.log

clean :
	rm -rf build