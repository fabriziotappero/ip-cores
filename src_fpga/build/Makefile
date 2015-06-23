#=======================================================================
# 6.375 Makefile for bsc-compile
#-----------------------------------------------------------------------
# $Id: Makefile,v 1.3 2008-06-26 17:52:59 jamey.hicks Exp $
#

default : all

basedir  = ../

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

# Library components

bsvclibdir = $(MIT6375_HOME)/install/bsvclib
bsvclibsrcs = \

# Bluespec sources

toplevel_module = mkTestBench

srcdir = $(basedir)
srcmem = ../../../MemController
bsvsrcs = \
	$(srcdir)/BRAM.bsv \
	$(srcdir)/H264Types.bsv \
	$(srcdir)/ExpGolomb.bsv \
	$(srcdir)/CAVLC.bsv \
	$(srcdir)/IH264.bsv \
	$(srcdir)/IInputGen.bsv \
	$(srcdir)/INalUnwrap.bsv \
	$(srcdir)/IEntropyDec.bsv \
	$(srcdir)/ICalc_nC.bsv \
	$(srcdir)/IMemED.bsv \
        $(srcdir)/IFPGAInterface.bsv \
        $(srcdir)/IEDKBRAM.bsv \
        $(srcdir)/IVgaController.bsv \
	$(srcdir)/IInverseTrans.bsv \
	$(srcdir)/IPrediction.bsv \
	$(srcdir)/IDeblockFilter.bsv \
	$(srcdir)/IBufferControl.bsv \
	$(srcdir)/IFinalOutput.bsv \
	$(srcdir)/mkH264.bsv \
	$(srcdir)/mkInputGen.bsv \
	$(srcdir)/mkNalUnwrap.bsv \
	$(srcdir)/mkEntropyDec.bsv \
	$(srcdir)/mkCalc_nC.bsv \
	$(srcdir)/mkMemED.bsv \
	$(srcdir)/mkInverseTrans.bsv \
	$(srcdir)/mkPrediction.bsv \
	$(srcdir)/mkDeblockFilter.bsv \
	$(srcdir)/mkBufferControl.bsv \
	$(srcdir)/mkFinalOutput.bsv \
	$(srcdir)/mkTH.bsv \
        $(srcdir)/mkTestBench.bsv \
        $(srcdir)/mkVgaController.bsv \
        $(srcdir)/MemControllerTypes.bsv \
	$(srcdir)/IMemClient.bsv \
	$(srcdir)/IMemClientBackend.bsv \
	$(srcdir)/IMemController.bsv \
        $(srcdir)/IMemScheduler.bsv \
	$(srcdir)/mkMemClient.bsv \
	$(srcdir)/mkBRAMMemController.bsv \
        $(srcdir)/mkRoundRobinMemScheduler.bsv \
        $(srcdir)/mkPriorityRoundRobinMemScheduler.bsv \
        $(srcdir)/BRAM.bsv \
        $(srcdir)/FIFO_2.bsv \
        $(srcdir)/mkSatCounter.bsv \
        $(srcdir)/SRAM.bsv \
        $(srcdir)/mkSRAMMemController.bsv \
        $(srcdir)/ISRAMWires.bsv \
        $(srcdir)/IInterpolator.bsv \
        $(srcdir)/mkInterpolator.bsv \
        $(srcdir)/mkFrameBuffer.bsv \
	$(srcdir)/IFrameBuffer.bsv \
	$(srcdir)/BlueBRAM.bsv \
	$(srcdir)/SRAMEmulator.bsv \
	$(srcdir)/BlueSRAM.bsv \
        $(srcdir)/IFPGA_FIFO.bsv \
        $(srcdir)/mkSizedFIFO_fpga.bsv \
#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

BSC_COMP = bsc
#BSC_OPTS = -u -show-module-use - -keep-fires -aggressive-conditions \
#           -relax-method-earliness -relax-method-urgency -v

BSC_OPTS = +RTS -K40000k --RTS -u -v -verilog -aggressive-conditions
 
# Copy over the bluespec source

$(notdir $(bsvsrcs)) : % : $(srcdir)/%
	cp $< .

$(notdir $(bsvclibsrcs)) : % : $(bsvclibdir)/%
	cp $< .

# Run the bluespec compiler

bsv_TH_vsrc = $(toplevel_module).v
$(bsv_TH_vsrc) $(bsv_lib_use) : $(notdir $(bsvsrcs) $(bsvclibsrcs))
	$(BSC_COMP) $(BSC_OPTS) -g $(toplevel_module) $(toplevel_module).bsv > out.log

compile : $(toplevel_module).v

# Create a schedule file

schedule_rpt = schedule.rpt
$(schedule_rpt) : $(notdir $(bsvsrcs) $(bsvclibsrcs))
	rm -rf *.v
	$(BSC_COMP) $(BSC_OPTS) -show-schedule -show-rule-rel \* \* -g $(toplevel_module) \
                $(toplevel_module).bsv >& $(schedule_rpt)

junk += $(notdir $(bsvsrcs)) $(notdir $(bsvclibsrcs)) \
	    $(schedule_rpt) *.use *.bi *.bo *.v bsc.log

#--------------------------------------------------------------------
# Default make target
#--------------------------------------------------------------------

all : compile

#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

clean :
	rm -rf $(junk) *~ \#* 
