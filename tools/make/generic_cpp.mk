# $Id: generic_cpp.mk 630 2015-01-04 22:43:32Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2015-01-04   630   1.0.3  use -Wextra
# 2011-11-28   434   1.0.2  use -fno-strict-aliasing, avoid warn from boost bind
# 2011-11-21   432   1.0.1  gcc 4.4.5 wants explict -fPIC for .so code
# 2011-01-09   354   1.0    Initial version (from wrepo/make/generic_cxx.mk)
#---
#
# Compile options
#
# -- handle C
#   -O       optimize
#   -fPIC    position independent code
#   -Wall    all warnings
#   -Wextra  extra warnings
#
ifdef CCCOMMAND
CC = $(CCCOMMAND)
endif
ifndef CCOPTFLAGS
CCOPTFLAGS = -O3
endif
#
CC         = gcc
CFLAGS     = -Wall -Wextra -fPIC
CFLAGS    += $(CCOPTFLAGS) $(INCLFLAGS)
#
# -- handle C++
#
#   -O3      optimize
#   -fPIC    position independent code
#   -Wall    all warnings
#   -Wextra  extra warnings
#
ifdef  CXXCOMMAND
CXX = $(CXXCOMMAND)
endif
#
ifndef CXXOPTFLAGS
CXXOPTFLAGS = -O3
endif
#
CXXFLAGS   = -Wall -Wextra -fPIC -fno-strict-aliasing -std=c++0x 
CXXFLAGS  += $(CXXOPTFLAGS) $(INCLFLAGS)
COMPILE.cc = $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
#
LINK.o     = $(CXX) $(CXXOPTFLAGS) $(LDOPTFLAGS) $(LDFLAGS) $(TARGET_ARCH)
LDFLAGS    = -g
#
# Compile rule
#
%.o: %.cpp
	$(COMPILE.cc) $< $(OUTPUT_OPTION)
#
