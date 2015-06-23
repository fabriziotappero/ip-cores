# $Id: Makefile,v 1.1.1.1 2006-02-04 03:35:00 freza Exp $

AXIS_USABLE_LIBS = UCLIBC GLIBC
include $(AXIS_TOP_DIR)/tools/build/Rules.axis

PROGS= 		boot

INSTDIR= 	$(prefix)/bin
INSTMODE= 	0755

SRCS= 		boot.c mcs.c
OBJS= 		boot.o mcs.o

CFLAGS+= 	-Wall -Werror

boot: $(OBJS)

all:	$(PROGS)

install:	$(PROGS)
	$(INSTALL) -d $(INSTDIR)
	$(INSTALL) -m 0755 $(PROGS) 	$(prefix)/bin
	#$(INSTALL) -m 0644 testled.mcs 	$(prefix)/

clean:
	rm -rf $(PROGS) *.o

depend:
	makedepend -Y -- $(CFLAGS) -- $(SRCS) 2>/dev/null

lo: all
	( cd .. ; ./_upload )
