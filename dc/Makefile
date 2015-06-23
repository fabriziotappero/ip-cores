#=======================================================================
# 6.375 Makefile for dc-synth
#-----------------------------------------------------------------------
# $Id: Makefile,v 1.2 2008-06-26 17:58:29 jamey.hicks Exp $
#
# This makefile will use Synopsys Design Compiler to synthesize
# your RTL into a gate-level verilog netlist.
#

default : all

basedir  = ../..

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

# bsvclib Verilog

bsvclibdir = $(MIT6375_HOME)/install/bsvclib
bsvclibsrcs = \

# Verilog from prelude

preludedir = $(BLUESPECDIR)/Verilog
preludesrcs = \
	$(preludedir)/FIFO2.v \
	$(preludedir)/RegFile.v \
	$(preludedir)/SizedFIFO.v \

# Verilog in source directory

vsrcdir = $(basedir)/src
vsrcs = \

# BSC generated verilog 

bscdir = ../build
bscsrcs = \
	$(bsrcdir)/mkH264.v \
	$(bsrcdir)/mkEntropyDec.v \
	$(bsrcdir)/mkCalc_nC.v \
	$(bsrcdir)/mkInverseTrans.v \
	$(bsrcdir)/mkPrediction.v \
        $(bsrcdir)/mkDeblockFilter.v \
        $(bsrcdir)/mkBufferControl.v \
        $(bsrcdir)/mkInterpolator.v \
        $(bsrcdir)/mkbSVector.v \
        $(bsrcdir)/mkLeftVector.v \
        $(bsrcdir)/mkTopVector.v \
        $(bsrcdir)/mkWorkVectorHor.v \
        $(bsrcdir)/mkWorkVectorVer.v \
	$(bsrcdir)/module_cavlc_coeff_token.v \
	$(bsrcdir)/module_cavlc_level_prefix.v \
	$(bsrcdir)/module_cavlc_run_before.v \
	$(bsrcdir)/module_cavlc_total_zeros.v \
	$(bsrcdir)/module_expgolomb_coded_block_pattern.v \
	$(bsrcdir)/module_expgolomb_codenum.v \
	$(bsrcdir)/module_expgolomb_numbits.v \
	$(bsrcdir)/module_expgolomb_signed.v \
	$(bsrcdir)/module_expgolomb_unsigned.v \
	$(bsrcdir)/module_expgolomb_codenum32.v \
	$(bsrcdir)/module_expgolomb_numbits32.v \
	$(bsrcdir)/module_expgolomb_signed32.v \
	$(bsrcdir)/module_expgolomb_unsigned32.v \

# Specify what the toplevel verilog module is

toplevel = mkH264

# Specify any instantiations which should be marked don't touch

dont_touch = \

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

build_suffix   := $(shell date +%Y-%m-%d_%H-%M)
build_dir      := build-$(build_suffix)
curr_build_dir := current
curr_build_dir_tstamp := current/timestamp.txt
synth_verilog  := $(curr_build_dir)/synthesized.v

synth_tcl      := synth.tcl
libs_tcl       := libs.tcl
synth_sdc      := synth.sdc
scripts        := $(synth_tcl) $(libs_tcl) $(synth_sdc)
makegen_tcl    := make_generated_vars.tcl

libdir = $(MIT6375_HOME)/libs/tsl180/tsl18fs120
synth_vars = \
	set SEARCH_PATH      { $(bvclibdir) $(preludedir) ../$(vsrcdir) ../${bscdir} }; \
	set DONT_TOUCH       { $(dont_touch) }; \
	set LINK_DBS         $(libdir)/db/tsl18fs120_typ.db; \
	set TARGET_DBS       $(libdir)/db/tsl18fs120_typ.db; \
	set SYMBOL_SDBS      $(libdir)/sdb/tsl18fs120_icon.sdb; \
	set VERILOG_SRCS     { $(notdir $(bsvclibsrcs) $(preludesrcs) $(vsrcs) $(bscsrcs)) }; \
	set VERILOG_TOPLEVEL $(toplevel); \

define new-build-dir-cmds
	mkdir $(build_dir)
	rm -f $(curr_build_dir)
	ln -s $(build_dir) $(curr_build_dir)
	cp $(scripts) $(curr_build_dir)
	echo '$(synth_vars)' > $(curr_build_dir)/$(makegen_tcl)
endef

new-build-dir :
	$(new-build-dir-cmds)

$(synth_verilog) : $(vsrcs) $(vclibsrcs) $(scripts) 
	$(new-build-dir-cmds)
	cd $(curr_build_dir); \
	dc_shell-xg-t -f $(synth_tcl) | tee dc.log; \
	cd ..

synth : $(synth_verilog)

junk += 

.PHONY : synth new-build-dir

#--------------------------------------------------------------------
# Default make target
#--------------------------------------------------------------------

all : synth

#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

clean :
	rm -rf build-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9] \
	       current $(junk) *~ \#*
