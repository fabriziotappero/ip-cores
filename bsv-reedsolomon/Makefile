# //----------------------------------------------------------------------//
# // The MIT License 
# // 
# // Copyright (c) 2008 Abhinav Agarwal, Alfred Man Cheuk Ng
# // Contact: abhiag@gmail.com
# // 
# // Permission is hereby granted, free of charge, to any person 
# // obtaining a copy of this software and associated documentation 
# // files (the "Software"), to deal in the Software without 
# // restriction, including without limitation the rights to use,
# // copy, modify, merge, publish, distribute, sublicense, and/or sell
# // copies of the Software, and to permit persons to whom the
# // Software is furnished to do so, subject to the following conditions:
# // 
# // The above copyright notice and this permission notice shall be
# // included in all copies or substantial portions of the Software.
# // 
# // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# // EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# // OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# // NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# // HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# // WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# // FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# // OTHER DEALINGS IN THE SOFTWARE.
# //----------------------------------------------------------------------//

#=======================================================================
# Makefile for Reed Solomon decoder
#-----------------------------------------------------------------------

default : mkTestBench

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------



# Bluespec sources

srcdir  = .
sim_srcdir = $(srcdir)/simulate

toplevel_module = mkTestBench


bsvsrcs = \
	$(srcdir)/RSParameters.bsv \
	$(srcdir)/GFTypes.bsv \
        $(srcdir)/GFArith.bsv \
	$(srcdir)/MFIFO.bsv \
        $(srcdir)/SyndromeParallel.bsv \
        $(srcdir)/Berlekamp.bsv \
        $(srcdir)/ChienSearch.bsv \
        $(srcdir)/ErrorMagnitude.bsv \
        $(srcdir)/ErrorCorrector.bsv \
        $(srcdir)/mkReedSolomon.bsv \
        $(srcdir)/file_interface.cpp \
        $(srcdir)/mkTestBench.bsv \
        $(srcdir)/funcunit.bsv 


sim_bsvsrcs = \


cppdir = $(srcdir)

cppsrcs = $(cppdir)/preproc.cpp

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

# compile & run the preproc to generate the GF inverse logic.

preproc.o : $(notdir $(cppsrcs))
	$(CXX) -c -o preproc.o preproc.cpp

preproc : preproc.o
	$(CXX) -o preproc preproc.o


GFInv.bsv : preproc $(notdir $(bsvsrcs))
	./preproc RSParameters.bsv GFInv.bsv

BSC_COMP = bsc

BSC_FLAGS = -u -aggressive-conditions -keep-fires -no-show-method-conf \
	-steps-warn-interval 200000 -steps-max-intervals 10 -show-schedule +RTS -K4000M -RTS

BSC_VOPTS = -elab -verilog 

BSC_BAOPTS = -sim

# run gcc

file_interface.o : file_interface.cpp
	gcc -c -DDATA_FILE_PATH=\"./input.dat\" \
	       -DOUT_DATA_FILE_PATH=\"./output.dat\" \
		file_interface.cpp

# Run the bluespec compiler


mkTestBench.ba : GFInv.bsv $(notdir $(bsvsrcs) $(sim_bsvsrcs))
	$(BSC_COMP) $(BSC_FLAGS) $(BSC_VOPTS) mkReedSolomon.bsv
	$(BSC_COMP) $(BSC_FLAGS) $(BSC_BAOPTS) -g $(toplevel_module) $(toplevel_module).bsv

mkTestBench : mkTestBench.ba file_interface.o
	$(BSC_COMP) $(BSC_BAOPTS) -e $(toplevel_module) *.ba file_interface.o


# Create a schedule file

schedule_rpt = schedule.rpt
$(schedule_rpt) : $(notdir $(bsvsrcs) $(bsvclibsrcs))
	rm -rf *.v
	$(BSC_COMP) $(BSC_FLAGS) $(BSC_BAOPTS) -show-schedule -show-rule-rel \* \* -g $(toplevel_module) $(toplevel_module).bsv


#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

junk += $(schedule_rpt)  *.use *.bi *.bo *.v bsc.log \
	diff.out *.sched  directc.*

.PHONY: clean

clean :
	rm -rf $(junk) *~ \#* *.h *.o *.cxx *.ba a.out preproc

