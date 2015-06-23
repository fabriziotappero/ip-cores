# $Id: xflow_default_nexys3.mk 477 2013-01-27 14:07:10Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-01-27   477   1.0    Initial version
#---
#
# Setup for Digilent Nexys3
#
# setup default board (for impact), device and userid (for bitgen)
#
ISE_BOARD = nexys3
ISE_PATH  = xc6slx16-csg324-2
#
# setup defaults for xflow option files for synthesis and implementation
#
ifndef XFLOWOPT_SYN
XFLOWOPT_SYN = syn_s6_speed.opt
endif
#
ifndef XFLOWOPT_IMP
XFLOWOPT_IMP = imp_s6_speed.opt
endif
#
