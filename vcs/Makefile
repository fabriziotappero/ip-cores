#=======================================================================
# 6.375 Makefile for vcs-sim-rtl
#-----------------------------------------------------------------------
# $Id: Makefile,v 1.4 2008-06-26 18:01:17 jamey.hicks Exp $
#
# This makefile will build a rtl simulator and run various tests to
# verify proper functionality.
#

default : all

basedir  = ../

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

# TSL library sources
tsllibs = $(MIT6375_HOME)/libs/tsl180/tsl18fs120/verilog/

# Verilog sources
testsrcdir = $(basedir)/build/
bsrcdir = $(basedir)/dc/current
verilogsrc = $(basedir)/src_verilog

vsrcs = \
	$(pardir)/par.v \
	$(testsrcdir)/mkTH.v \
	$(verilogsrc)/top.v \
#	$(bsrcdir)/mkbSVector.v \
#	$(bsrcdir)/mkBufferControl.v \
#	$(bsrcdir)/mkCalc_nC.v \
#	$(bsrcdir)/mkDeblockFilter.v \
#	$(bsrcdir)/mkEntropyDec.v \
#	$(bsrcdir)/mkH264.v \
#	$(bsrcdir)/mkInterpolator.v \
#	$(bsrcdir)/mkInverseTrans.v \
#	$(bsrcdir)/mkLeftVector.v \
#	$(bsrcdir)/mkPrediction.v \
#	$(bsrcdir)/mkTH.v \
#	$(bsrcdir)/mkTopVector.v \
#	$(bsrcdir)/mkWorkVectorHor.v \
#	$(bsrcdir)/mkWorkVectorVer.v \
#	$(bsrcdir)/module_cavlc_coeff_token.v \
#	$(bsrcdir)/module_cavlc_level_prefix.v \
#	$(bsrcdir)/module_cavlc_run_before.v \
#	$(bsrcdir)/module_cavlc_total_zeros.v \
#	$(bsrcdir)/module_expgolomb_coded_block_pattern.vmodule_expgolomb_codenum32.v \
#	$(bsrcdir)/module_expgolomb_codenum.v \
#	$(bsrcdir)/module_expgolomb_numbits32.v \
#	$(bsrcdir)/module_expgolomb_numbits.v \
#	$(bsrcdir)/module_expgolomb_signed32.v \
#	$(bsrcdir)/module_expgolomb_signed.v \
#	$(bsrcdir)/module_expgolomb_unsigned32.v \
#	$(bsrcdir)/module_expgolomb_unsigned.v \



#Myron told me to add you
vclibdir  = $(MIT6375_HOME)/install/bsvclib
vclibsrcs = \
	$(vclibdir)/mkEHRReg4.v \
	$(vclibdir)/mkResetRegFileFull_h.v \
	$(tsllibs)/mtb_verilog.v \

bsclibdir = $(BLUESPECDIR)/Verilog
bsclibsrcs = \
	$(bsclibdir)/FIFO2.v \
	$(bsclibdir)/RegFile.v \
	$(bsclibdir)/RegFileLoad.v \

testscriptsdir = $(basedir)/test
testfilesdir = $(basedir)/test/h264
testfiles = \
	$(testfilesdir)/x264foreman_qcif1-5.264 \

pardir = $(basedir)/enc-par/current



#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

VCS      = vcs
VCS_OPTS = -notice -PP -line +lint=all +v2k -timescale=1ns/10ps 




# Task for setting up the test case
define setup-test
	cp $(1) input.264
	cp $(1) input.hex # This line is dirty, but it will avoid the problem of not having hex files. 
	rm *.hex
        perl $(testscriptsdir)/hexfilegen.pl input.264
	wc input.264 | awk '{printf("%08x\n%08x\n%08x\n%08x\n", $$3, $$3, $$3, $$3)}' > input_size.hex
endef

#------------------------------------------------------------
# Build the processor simulator

vcs_sim = simv

par-sdf:
	cp $(pardir)/postroute.sdf ./top.sdf

$(vcs_sim) : $(vsrcs) par-sdf
	$(VCS) $(VCS_OPTS) +incdir+$(tsllibs) -o $(vcs_sim) +csdf+precompile +sdfverbose\
		  +libext+.v -y $(tsllibs) \
	       +incdir+$(vclibdir) $(addprefix -v ,$(vclibsrcs)) +incdir+$(bsclibdir) $(addprefix -v ,$(bsclibsrcs)) $(vsrcs)

sim-rtl : $(vcs_sim)

foreman : sim-rtl
	$(call setup-test, $(testfilesdir)/x264foreman_qcif1-5.264) 

junk += simv* csrc *.vpd vcs.key

#--------------------------------------------------------------------
# Default make target
#--------------------------------------------------------------------

all : foreman

#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

clean :
	rm -rf $(objs) $(junk) *~ \#* *.log *.cmd *.daidir *.sdf *.hex *.v *.264 *.sdf_c *.vcd
