# $Id: generic_isim.mk 642 2015-02-06 18:53:12Z mueller $
#
# Copyright 2009-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-10-12   539   1.3    use xtwi
# 2013-01-27   477   1.2.1  use dontincdep.mk to suppress .dep include on clean
# 2011-08-13   405   1.2    renamed, moved to rtl/make;
# 2010-04-26   284   1.1    add _[sft]sim support
# 2009-11-22   252   1.0    Initial version
#
FUSE = fuse
#
%_ISim : %.vbom
	vbomconv -isim_prj $< > $*_isim.prj
	xtwi $(FUSE) $* -prj $*_isim.prj -o $*_ISim
	rm -rf $*_isim.prj
#
# rule for _ssim to call FUSE with right top level name
#
%_ISim_ssim : %_ssim.vbom
	vbomconv -isim_prj $*_ssim.vbom > $*_isim_ssim.prj
	xtwi $(FUSE) $* -prj $*_isim_ssim.prj -o $*_ISim_ssim
	rm -rf $*_isim_ssim.prj
#
# rule for _[ft]sim to use 'virtual' _[ft]sim vbom's (derived from _ssim)
#
%_ISim_fsim : %_ssim.vbom
	vbomconv -isim_prj $*_fsim.vbom > $*_isim_fsim.prj
	xtwi $(FUSE) $* -prj $*_isim_fsim.prj -o $*_ISim_fsim
	rm -rf $*_isim_fsim.prj
#
%_ISim_tsim : %_ssim.vbom
	vbomconv -isim_prj $*_tsim.vbom > $*_isim_tsim.prj
	xtwi $(FUSE) $* -prj $*_isim_tsim.prj -o $*_ISim_tsim
	rm -rf $*_isim_tsim.prj
#
%.dep_isim: %.vbom
	vbomconv --dep_isim $< > $@
#
include $(RETROBASE)/rtl/make_ise/dontincdep.mk
#
.PHONY: isim_clean isim_tmp_clean
#
isim_clean: isim_tmp_clean
	rm -f $(EXE_all:%=%_ISim)
	rm -f $(EXE_all:%=%_ISim_ssim)
	rm -f $(EXE_all:%=%_ISim_fsim)
	rm -f $(EXE_all:%=%_ISim_tsim)
#
isim_tmp_clean:
	rm -f isim.log isim.wdb
	rm -f fuse.log
	rm -rf isim
#
