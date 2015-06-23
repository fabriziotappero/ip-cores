# $Id: generic_ghdl.mk 646 2015-02-15 12:04:55Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
#  Revision History: 
# Date         Rev Version  Comment
# 2015-02-14   646   1.0    Initial version (cloned from make_ise)
#
GHDLIEEE    = --ieee=synopsys
GHDLXLPATH  = $(XTWV_PATH)/ghdl
#
% : %.vbom
	vbomconv --ghdl_i $<
	vbomconv --ghdl_m --xlpath=$(GHDLXLPATH) $<
#
# rules for _[o]sim to use 'virtual' [o]sim vbom's  (derived from _ssim)
#
%_osim : %_ssim.vbom
	vbomconv --ghdl_i $*_osim.vbom
	vbomconv --ghdl_m --xlpath=$(GHDLXLPATH) $*_osim.vbom
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
	rm -f $(EXE_all:%=%_[so]sim)
	rm -f cext_*.o
#
ghdl_tmp_clean:
	find -maxdepth 1 -name "*.o" | grep -v "^\./cext_" | xargs rm -f
	rm -f work-obj93.cf
#
