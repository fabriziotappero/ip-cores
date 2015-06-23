# $Id: generic_vivado.mk 646 2015-02-15 12:04:55Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History: 
# Date         Rev Version  Comment
# 2015-02-15   646   1.0    Initial version
# 2015-01-25   637   0.1    First draft
#---
#
# check that part is defined
#
ifndef VIV_BOARD_SETUP
$(error VIV_BOARD_SETUP is not defined)
endif
#
# ensure that default tools and flows are defined
#
ifndef VIV_INIT
VIV_INIT = $(RETROBASE)/rtl/make_viv/viv_init.tcl
endif
ifndef VIV_BUILD_FLOW
VIV_BUILD_FLOW = $(RETROBASE)/rtl/make_viv/viv_default_build.tcl
endif
ifndef VIV_CONFIG_FLOW
VIV_CONFIG_FLOW = $(RETROBASE)/rtl/make_viv/viv_default_config.tcl
endif
ifndef VIV_MODEL_FLOW
VIV_MODEL_FLOW = $(RETROBASE)/rtl/make_viv/viv_default_model.tcl
endif
#
# $@ first target
# $< first dependency
# $* stem in rule match
#
# when chaining, don't delete 'expensive' intermediate files:
.SECONDARY : 
#
# Synthesize + Implement -> generate bit file
#   input:   %.vbom     vbom project description
#   output:  %.bit
#
%.bit : %.vbom
	rm -rf project_mflow
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_BOARD_SETUP} \
		-source ${VIV_BUILD_FLOW} \
		-tclargs $* bit
#
# Configure FPGA with vivado hardware server
#   input:   %.bit
#   output:  .PHONY
#
%.vconfig : %.bit
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_BOARD_SETUP} \
		-source ${VIV_CONFIG_FLOW} \
		-tclargs $*
#
# Partial Synthesize + Implement -> generate dcp for model generation
#
%_syn.dcp : %.vbom
	rm -rf project_mflow
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_BOARD_SETUP} \
		-source ${VIV_BUILD_FLOW} \
		-tclargs $* syn
%_opt.dcp %_rou.dcp : %.vbom
	rm -rf project_mflow
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_BOARD_SETUP} \
		-source ${VIV_BUILD_FLOW} \
		-tclargs $* imp
#
# Post-synthesis functional simulation model (Vhdl/Unisim)
#   input:   %_syn.dcp
#   output:  %_ssim.vhd
#
%_ssim.vhd : %_syn.dcp
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_MODEL_FLOW} \
		-tclargs $* ssim
#
# Post-optimization functional simulation model (Vhdl/Unisim)
#   input:   %_opt.dcp
#   output:  %_osim.vhd
#
%_osim.vhd : %_opt.dcp
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_MODEL_FLOW} \
		-tclargs $* osim
#
# Post-routing timing simulation model (Verilog/Simprim)
#   input:   %_rou.dcp
#   output:  %_tsim.v
#            %_tsim.sdf
#
%_tsim.v %_tsim.sdf : %_rou.dcp
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_MODEL_FLOW} \
		-tclargs $* tsim
#
# vivado project quick starter
#
.PHONY : vivado
vivado :
	xtwv vivado -mode gui project_mflow/project_mflow.xpr

#
# generate dep_vsyn files from vbom
#
%.dep_vsyn: %.vbom
	vbomconv --dep_vsyn $< > $@

#
# Cleanup
#
include $(RETROBASE)/rtl/make_viv/dontincdep.mk
#
.PHONY : viv_clean viv_tmp_clean
#
viv_clean: viv_tmp_clean
	rm -f *.bit
	rm -f *.dcp
	rm -f *.jou
	rm -f *.log
	rm -f *.rpt
	rm -f *_[so]sim.vhd
	rm -f *_tsim.v
	rm -f *_tsim.sdf
#
viv_tmp_clean:
	rm -rf ./project_mflow
#
