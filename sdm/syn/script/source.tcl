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
# Source files for the wormhole/SDM routers
# 
# History:
# 26/05/2011  Initial version. <wsong83@gmail.com>
# 02/06/2011  Use separated comp4 file. <wsong83@gmail.com>

# the common verilog source files between VC and SDM
analyze -format verilog   ../../common/src/cell_lib.v
analyze -format verilog   ../../common/src/ctree.v
analyze -format sverilog  ../../common/src/dcb.v
analyze -format sverilog  ../../common/src/dcb_xy.v
analyze -format sverilog  ../../common/src/dclos.v
analyze -format sverilog  ../../common/src/mnma.v
analyze -format sverilog  ../../common/src/mrma.v
analyze -format verilog   ../../common/src/mutex_arb.v
analyze -format sverilog  ../../common/src/pipe4.v
analyze -format sverilog  ../../common/src/rcb.v
analyze -format verilog   ../../common/src/tree_arb.v
analyze -format verilog   ../../common/src/comp4.v

# the private code of wormhole/SDM routers
analyze -format sverilog  ../src/clos_sch.v
analyze -format sverilog  ../src/cm_alloc.v
analyze -format sverilog  ../src/im_alloc.v
analyze -format sverilog  ../src/input_buf.v
analyze -format sverilog  ../src/output_buf.v
analyze -format sverilog  ../src/router.v
analyze -format sverilog  ../src/sdm_sch.v
analyze -format sverilog  ../src/subc_ctl.v
