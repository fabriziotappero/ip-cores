# $Id: xflow_default_nexys4.mk 534 2013-09-22 21:37:24Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-09-21   534   1.0    Initial version
#---
#
# Setup for Digilent Nexys4
#
# setup default board (for impact), device and userid (for bitgen)
#
ISE_BOARD = nexys4
ISE_PATH  = xc7a100t-csg324-1
#
# setup defaults for xflow option files for synthesis and implementation
#
ifndef XFLOWOPT_SYN
XFLOWOPT_SYN = syn_7a_speed.opt
endif
#
ifndef XFLOWOPT_IMP
XFLOWOPT_IMP = imp_7a_speed.opt
endif
#
