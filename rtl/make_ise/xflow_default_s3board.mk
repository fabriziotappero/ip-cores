# $Id: xflow_default_s3board.mk 477 2013-01-27 14:07:10Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-01-27   477   1.0    Initial version
#---
#
# Setup for Digilent S3BOARD (with 1000 die size)
#
# setup default board (for impact), device and userid (for bitgen)
#
ISE_BOARD = s3board
ISE_PATH  = xc3s1000-ft256-4
#
# setup defaults for xflow option files for synthesis and implementation
#
ifndef XFLOWOPT_SYN
XFLOWOPT_SYN = syn_s3_speed.opt
endif
#
ifndef XFLOWOPT_IMP
XFLOWOPT_IMP = imp_s3_speed.opt
endif
#
