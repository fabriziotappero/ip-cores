# $Id: Makefile,v 1.1.1.1 2006-02-04 03:35:01 freza Exp $

AXIS_USABLE_LIBS = UCLIBC GLIBC
include $(AXIS_TOP_DIR)/tools/build/Rules.axis

PROGS= 		bus

INSTDIR= 	$(prefix)/bin
INSTMODE= 	0755

SRCS= 		bus.c
OBJS= 		bus.o

CFLAGS+= 	-Wall -Werror

boot: $(OBJS)

all:	$(PROGS)

install:	$(PROGS)
	$(INSTALL) -d $(INSTDIR)
	$(INSTALL) -m $(INSTMODE) $(PROGS) $(INSTDIR)

clean:
	rm -rf $(PROGS) *.o

depend:
	makedepend -Y -- $(CFLAGS) -- $(SRCS) 2>/dev/null
