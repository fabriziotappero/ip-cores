#Makefile Mips R2000 developed by Igor Loi
#v 1.0 2004/12/05 21:42 Diee Cagliari
# Thanks to Nicolai Ascanium from IMM

TARGET_ARCH = linux

CC     = g++
OPT    = -O3
DEBUG  = -g
OTHER  = -Wall
CFLAGS = $(OPT) $(OTHER)
# CFLAGS = $(DEBUG) $(OTHER)
MODULE = mips2
SRCS = timer.cpp
	   
OBJS 	= $(SRCS:.cpp=.o)
DEPS	= $(SRCS:.cpp=.d)


%.o : %.cpp
	$(CC) $(INCDIR) $(LIBDIR) $(EXTRA) $(CFLAGS) -c -o $@ $<

%.d: %.cpp
	set -e; $(CC) -MM $(INCDIR) $(LIBDIR) $(CFLAGS) $(EXTRA) $< | sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' > $@; \
	[ -s $@ ] || rm -f $@

%.o : %.cc
	$(CC) $(INCDIR) $(LIBDIR) $(EXTRA) $(CFLAGS) -c -o $@ $<

%.d: %.cc
	set -e; $(CC) -MM $(INCDIR) $(LIBDIR) $(CFLAGS) $(EXTRA) $< | sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' > $@; \
	[ -s $@ ] || rm -f $@


$(MODULE): $(OBJS)
	$(CC) $(CFLAGS) $(INCDIR) $(LIBDIR) -o $@ $(OBJS) $(LIBS) 2>&1 | c++filt


include ./Makefile.defs
