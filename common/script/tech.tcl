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
# Script for cell library setting up.
# currently using the Nangate 45nm cell lib.
# 
# History:
# 05/07/2009  Initial version. <wsong83@gmail.com>
# 20/05/2011  Change to the Nangate cell library. <wsong83@gmail.com>

set rm_lib_dirs         "../../lib"

set rm_library         "Nangate_typ.db"

set search_path         [concat ${search_path} "${rm_lib_dirs}/" ".."]

set synthetic_library   dw_foundation.sldb
set link_library        [list *]
set link_library        [concat ${link_library} ${rm_library} $synthetic_library]
set target_library      "${rm_library}"

