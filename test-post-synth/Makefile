#=======================================================================
# 6.375 Makefile for vcs-sim-rtl
#-----------------------------------------------------------------------
# $Id: Makefile,v 1.1 2008-06-26 18:11:24 jamey.hicks Exp $
#
# This makefile will build a rtl simulator and run various tests to
# verify proper functionality.
#

default : all

basedir  = ../..

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

# Library components


# Verilog sources
verilogsrcdir = ../src_verilog
synthsrcdir = ../dc/current
srcdir = ../build/
vclibdir = /mit/6.375/libs/tsl180/tsl18fs120/verilog/
bsclibdir = /mit/6.375/tools/bluespec/Bluespec-2007.03/lib/Verilog/
vsrcs = \
	$(verilogsrcdir)/top.v \
	$(srcdir)/mkTH.v \
	$(synthsrcdir)/synthesized.v \
        /mit/6.375/libs/tsl180/tsl18fs120/distrib/tsl18/v3.0/verilog/tsl18fs120/zero/mtb_verilog.v \

# Globally installed assembly tests


VCS      = vcs
VCS_OPTS = -notice -PP -line +v2k -timescale=1ns/1ps


VPATH += $(addprefix $(global_bmarkdir)/, $(global_bmarks)) \
         $(addprefix $(local_bmarkdir)/, $(local_bmarks))

incs  += -I. $(addprefix -I$(global_bmarkdir)/, $(global_bmarks)) \
             $(addprefix -I$(local_bmarkdir)/, $(local_bmarks))

#------------------------------------------------------------
# Build the processor simulator

vcs_sim = simv
$(vcs_sim) : $(vsrcs)
	$(VCS) $(VCS_OPTS) +incdir+$(srcdir) +incdir+$(synthsrcdir)  -o $(vcs_sim) \
	       -y $(vclibdir) -y $(bsclibdir) +libext+.v+ $(addprefix -v ,$(vlibsrcs)) $(vsrcs)

junk += simv* csrc *.vpd vcs.key


all : $(vcs_sim)

#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

clean :
	rm -rf $(junk) *~ \#* *.log *.cmd *.daidir
