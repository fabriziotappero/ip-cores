# $Id: checkpath_cpp.mk 602 2014-11-08 21:42:47Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2014-11-08   602   1.1    add default for TCLLIB
# 2013-03-01   493   1.0.1  fix logic
# 2013-02-01   479   1.0    Initial version
#
ifndef RETROBASE
$(error RETROBASE not defined)
endif
#
# check that BOOSTLIB/BOOSTINC are defined either both, or none 
#
ifndef BOOSTINC
ifdef BOOSTLIB
$(error BOOSTLIB defined, but not BOOSTINC; either both, or none !!)
endif
endif
#
ifndef BOOSTLIB
ifdef BOOSTINC
$(error BOOSTINC defined, but not BOOSTLIB; either both, or none !!)
endif
endif
#
# now define, if needed
#
ifndef BOOSTINC
BOOSTINC = /usr/include
endif
#
ifndef BOOSTLIB
BOOSTLIB = /usr/lib
endif
#
# define TCLLIB, if needed
#
ifndef TCLLIB
TCLLIB = /usr/lib
endif
