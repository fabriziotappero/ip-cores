#//----------------------------------------------------------------------//
#// The MIT License 
#// 
#// Copyright (c) 2008 Kermin Fleming, kfleming@mit.edu 
#// 
#// Permission is hereby granted, free of charge, to any person 
#// obtaining a copy of this software and associated documentation 
#// files (the "Software"), to deal in the Software without 
#// restriction, including without limitation the rights to use,
#// copy, modify, merge, publish, distribute, sublicense, and/or sell
#// copies of the Software, and to permit persons to whom the
#// Software is furnished to do so, subject to the following conditions:
#// 
#// The above copyright notice and this permission notice shall be
#// included in all copies or substantial portions of the Software.
#// 
#// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#// OTHER DEALINGS IN THE SOFTWARE.
#//----------------------------------------------------------------------//


default : all

basedir  = ../
bsvlibdir = ../../../bsclib
verilogdir = ./


#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

# Library components

bsvclibdir = $(MIT6375_HOME)/install/bsvclib
bsvclibsrcs = \

# Bluespec sources

toplevel_module = mkTestBench

srcdir = $(basedir)


fpgasrcs = \
        $(srcdir)/BRAMFIFO.bsv \
        $(srcdir)/mkTestBench.bsv \
	$(srcdir)/top.v \
        $(srcdir)/BRAMFIFOF.v       



#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

BSC_COMP = bsc
#BSC_OPTS = -u -show-module-use - -keep-fires -aggressive-conditions \
#           -relax-method-earliness -relax-method-urgency -v

BSC_OPTS_SIM = +RTS -K400000k --RTS -u -v -sim -aggressive-conditions


BSC_OPTS_VERILOG = +RTS -K400000k --RTS -u -v -verilog -aggressive-conditions -dschedule

BSIM_OPTS = +RTS -K400000k --RTS -sim 

# Copy over te bluespec source

$(notdir $(fpgasrcs)) : % : $(srcdir)/%
	cp $< .

$(notdir $(bsvclibsrcs)) : % : $(bsvclibdir)/%
	cp $< .

# Run the bluespec compiler

bsv_TH_vsrc = $(toplevel_module).v
$(bsv_TH_vsrc) $(bsv_lib_use) : $(notdir $(fpgasrcs) $(bsvclibsrcs))
	$(BSC_COMP) $(BSC_OPTS_SIM) -g $(toplevel_module) $(toplevel_module).bsv > out.log

bsv : $(toplevel_module).v


blue_sim: $(bsv_TH_vsrc)
	$(BSC_COMP) $(BSIM_OPTS) -e $(toplevel_module) *.ba > out.txt

verilog: $(notdir $(fpgasrcs) $(bsvclibsrcs))
	$(BSC_COMP) $(BSC_OPTS_VERILOG) -g $(toplevel_module) $(toplevel_module).bsv > out.log  

verilog_exec: verilog
	iverilog -y$(bsvlibdir) -y$(verilogdir) *.v


# Create a schedule file

schedule_rpt = schedule.rpt
$(schedule_rpt) : $(notdir $(fpgasrcs) $(bsvclibsrcs))
	rm -rf *.v
	$(BSC_COMP) $(BSC_OPTS_SIM) -show-schedule -show-rule-rel \* \* -g $(toplevel_module) \
                $(toplevel_module).bsv >& $(schedule_rpt)

junk += $(notdir $(fpgasrcs) ) $(notdir $(bsvclibsrcs)) \
	    $(schedule_rpt) *.use *.bi *.bo *.v bsc.log

#--------------------------------------------------------------------
# Default make target
#--------------------------------------------------------------------

all : verilog_exec

#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

clean :
	rm -rf $(junk) *~ \#* *.cxx *.o *.h *.ba
