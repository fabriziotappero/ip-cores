# $Id: generic_xflow_cpld.mk 642 2015-02-06 18:53:12Z mueller $
#
# Copyright 2010-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-10-12   539   1.2    use xtwi
# 2013-01-05   470   1.1.1  remove '-r' from all non-dir clean rm's
# 2011-08-13   405   1.1    renamed, moved to rtl/make;
# 2010-03-13   268   1.0    Initial version, cloned from .xflow Rev 252
#---
#
# setup default device
#
ifndef ISE_PATH
ISE_PATH =  xc2c64a-7-vq44
endif
#
# setup defaults for xflow option files for synthesis and implementation
#
ifndef XFLOWOPT_SYN
XFLOWOPT_SYN = xst_vhdl.opt
endif
#
ifndef XFLOWOPT_IMP
XFLOWOPT_IMP = balanced.opt
endif
#
XFLOW    = xflow -p ${ISE_PATH} 
#
# $@ first target
# $< first dependency
# $* stem in rule match
#
# when chaining, don't delete 'expensive' intermediate files:
.SECONDARY : 
#
# Synthesize (xst)
#   input:   %.prj      project file
#   output:  %.ngc
#            %_xst.log  xst log file
#
# Note: removed "cp ${RETROBASE}/vlib/${XFLOWOPT_SYN} ./ise" option
#
%.ngc: %.vbom
	if [ ! -d ./ise ]; then mkdir ./ise; fi
	(cd ./ise; vbomconv --xst_prj ../$< > $*.prj)
	(cd ./ise; touch $*.xcf)
	if [ -r  $*.xcf ]; then cp $*.xcf ./ise; fi
	if [ -r ${XFLOWOPT_SYN} ]; then cp ${XFLOWOPT_SYN} ./ise; fi
	xtwi ${XFLOW} -wd ise -synth ${XFLOWOPT_SYN} $*.prj 
	(cd ./ise; chmod -x *.* )
	if [ -r ./ise/$*.ngc ]; then cp -p ./ise/$*.ngc .; fi
	if [ -r ./ise/$*_xst.log ]; then cp -p ./ise/$*_xst.log .; fi
	@ echo "==============================================================="
	@ echo "*     Makefile.xflow: XST Diagnostic Summary                  *"
	@ echo "==============================================================="
	@ grep -i -A 1 ":.*:" $*_xst.log
	@ echo "==============================================================="
#
# the following rule needed to generate an %_*sim.vhd in a ./tb sub-directory
# it will look for a matching vbom in the parent directory
%.ngc: ../%.vbom
	if [ ! -d ./ise ]; then mkdir ./ise; fi
	(cd ./ise; vbomconv --xst_prj ../$< > $*.prj)
	(cd ./ise; touch $*.xcf)
	if [ -r  $*.xcf ]; then cp $*.xcf ./ise; fi
	if [ -r ${XFLOWOPT_SYN} ]; then cp ${XFLOWOPT_SYN} ./ise; fi
	xtwi ${XFLOW} -wd ise -synth ${XFLOWOPT_SYN} $*.prj 
	(cd ./ise; chmod -x *.* )
	if [ -r ./ise/$*.ngc ]; then cp -p ./ise/$*.ngc .; fi
	if [ -r ./ise/$*_xst.log ]; then cp -p ./ise/$*_xst.log .; fi
	@ echo "==============================================================="
	@ echo "*     Makefile.xflow: XST Diagnostic Summary                  *"
	@ echo "==============================================================="
	@ grep -i -A 1 ":.*:" $*_xst.log
	@ echo "==============================================================="
#
# Fit (map + cpldfit + 
#   input:   %.ngc      project file
#   output:  %.ncd
#            %.jed
#            %_tra.log  translate (ngdbuild) log file (renamed %.bld)
#            %_fit.log  cpldfit log file              (renamed %.rpt)
#            %_tim.log  timing analyser log file      (renamed %.tim)
#            %_pad.log  pad file                      (renamed %.pad)
#
# Note: removed "cp ${RETROBASE}/vlib/balanced.opt" option
#       currently ise 'density.opt' as steering file
#
%.ncd %.jed: %.ngc
	if [ ! -d ./ise ]; then mkdir ./ise; fi
	if [ -r $*.ngc ]; then cp -p $*.ngc ./ise; fi
	if [ -r $*.ucf ]; then cp -p $*.ucf ./ise; fi
	if [ -r ${XFLOWOPT_IMP} ]; then cp -p ${XFLOWOPT_IMP} ./ise; fi
	xtwi ${XFLOW} -wd ise -fit ${XFLOWOPT_IMP} $<
	(cd ./ise; chmod -x *.* )
	if [ -r ./ise/$*.ncd ]; then cp -p ./ise/$*.ncd .; fi
	if [ -r ./ise/$*.jed ]; then cp -p ./ise/$*.jed .; fi
	if [ -r ./ise/$*.bld ]; then cp -p ./ise/$*.bld ./$*_tra.log; fi
	if [ -r ./ise/$*.rpt ]; then cp -p ./ise/$*.rpt ./$*_fit.log; fi
	if [ -r ./ise/$*.tim ]; then cp -p ./ise/$*.tim ./$*_tim.log; fi
	if [ -r ./ise/$*.pad ]; then cp -p ./ise/$*.pad ./$*_pad.log; fi
#
# generate dep_xst files from vbom
#
%.dep_xst: %.vbom
	vbomconv --dep_xst $< > $@
#
# generate cpp'ed ucf files from ucf_cpp
#
%.ucf : %.ucf_cpp
	cpp $*.ucf_cpp $*.ucf
#
# generate nested dependency rules for cpp'ed ucf files from ucf_cpp
#
%.dep_ucf_cpp : %.ucf_cpp
	cpp -MM $*.ucf_cpp | sed 's/\.o:/\.ucf:/' > $*.dep_ucf_cpp
#
.PHONY : ise_clean ise_tmp_clean
#
ise_clean: ise_tmp_clean
	rm -f *.ngc
	rm -f *.ncd
	rm -f *.jed
	rm -f *_xst.log
	rm -f *_tra.log
	rm -f *_fit.log
	rm -f *_tim.log
	rm -f *_pad.log
#
ise_tmp_clean:
	rm -rf ./ise
#
