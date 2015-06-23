#=========================================================================
# TCL Script File for Design Compiler Library Setup
#-------------------------------------------------------------------------
# $Id: libs.tcl,v 1.1 2008-06-26 17:58:18 jamey.hicks Exp $
# 

# The makefile will generate various variables which we now read in

source make_generated_vars.tcl

# The following commands setup the standard cell libraries

set synthetic_library [list dw_foundation.sldb]
set link_library      [list {*} dw_foundation.sldb ${LINK_DBS}]
set target_library    [list ${TARGET_DBS}]                    
set symbol_library    [list ${SYMBOL_SDBS}]                    

# The search path needs to point to the verilog source directory

lappend search_path ${SEARCH_PATH}

# This is the location of the synopsys work directory

define_design_lib WORK -path "work"

