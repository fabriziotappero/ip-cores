# Asynchronous SDM NoC
# (C)2011 Wei Song
# Advanced Processor Technologies Group
# Computer Science, the Univ. of Manchester, UK
# 
# Authors: 
# Wei Song     wsong83@gmail.com
# 
# License: LGPL 3.0 or later
# 
# Source files for the VC routers
# 
# History:
# 02/06/2011  Initial version. <wsong83@gmail.com>

# the common verilog source files between VC and SDM
analyze -format verilog   ../../common/src/cell_lib.v
analyze -format verilog   ../../common/src/ctree.v
analyze -format sverilog  ../../common/src/mnma.v
analyze -format sverilog  ../../common/src/mrma.v
analyze -format verilog   ../../common/src/mutex_arb.v
analyze -format sverilog  ../../common/src/pipe4.v
analyze -format sverilog  ../../common/src/pipen.v
analyze -format verilog   ../../common/src/tree_arb.v
analyze -format verilog   ../../common/src/comp4.v

# the private code of wormhole/SDM routers
analyze -format sverilog  ../src/cpipe.v
analyze -format sverilog  ../src/dcb_vc.v
analyze -format sverilog  ../src/ddmux.v
analyze -format sverilog  ../src/inpbuf.v
analyze -format sverilog  ../src/outpbuf.v
analyze -format sverilog  ../src/router.v
analyze -format sverilog  ../src/fcctl.v
analyze -format sverilog  ../src/rcb_vc.v
analyze -format sverilog  ../src/rtu.v
analyze -format sverilog  ../src/vca.v
analyze -format sverilog  ../src/vcdmux.v
