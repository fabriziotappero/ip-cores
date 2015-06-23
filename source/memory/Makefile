TARGET_ARCH = linux

CC     = g++
OPT    = -O3
DEBUG  = -g
OTHER  = -Wall
CFLAGS = $(OPT) $(OTHER)
# CFLAGS = $(DEBUG) $(OTHER)  ram16x1d.cpp

MODULE = D_M
SRCS   = memory2.cpp

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
