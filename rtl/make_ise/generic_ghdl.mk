# $Id: generic_ghdl.mk 646 2015-02-15 12:04:55Z mueller $
#
# Copyright 2007-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
#  Revision History: 
# Date         Rev Version  Comment
# 2015-02-14   646   1.4    use --xlpath for vbomconv; drop cygwin support;
# 2014-07-26   575   1.3.2  use XTWI_PATH now (ise/vivado switch done later)
# 2013-01-27   477   1.3.1  use dontincdep.mk to suppress .dep include on clean
# 2011-08-13   405   1.3    renamed, moved to rtl/make;
# 2007-11-04    95   1.2.2  fix find statement in ghdl_tmp_clean
# 2007-11-02    94   1.2.1  don't delete cext_*.o in ghdl_tmp_clean
# 2007-07-08    65   1.2    support now autobuilding of _fsim and _tsim models
# 2007-06-16    57   1.1    cleanup ghdl_clean handling 
# 2007-06-10    52   1.0    Initial version
#
GHDLIEEE    = --ieee=synopsys
GHDLXLPATH  = $(XTWI_PATH)/ISE_DS/ISE/ghdl
#
% : %.vbom
	vbomconv --ghdl_i $<
	vbomconv --ghdl_m --xlpath=$(GHDLXLPATH) $<
#
# rules for _[ft]sim to use 'virtual' [ft]sim vbom's  (derived from _ssim)
#
%_fsim : %_ssim.vbom
	vbomconv --ghdl_i $*_fsim.vbom
	vbomconv --ghdl_m --xlpath=$(GHDLXLPATH) $*_fsim.vbom
#
%_tsim : %_ssim.vbom
	vbomconv --ghdl_i $*_tsim.vbom
	vbomconv --ghdl_m --xlpath=$(GHDLXLPATH) $*_tsim.vbom
#
%.dep_ghdl: %.vbom
	vbomconv --dep_ghdl $< > $@
#
include $(RETROBASE)/rtl/make_ise/dontincdep.mk
#
.PHONY: ghdl_clean ghdl_tmp_clean
#
ghdl_clean: ghdl_tmp_clean
	rm -f $(EXE_all)
	rm -f $(EXE_all:%=%_[sft]sim)
	rm -f cext_*.o
#
ghdl_tmp_clean:
	find -maxdepth 1 -name "*.o" | grep -v "^\./cext_" | xargs rm -f
	rm -f work-obj93.cf
#
