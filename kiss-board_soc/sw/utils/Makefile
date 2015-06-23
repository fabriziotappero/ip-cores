PROGRAMS = bin2c bin2srec bin2flimg bin2hex bin2uart bin2bin
# NB: 'loader' not in that list

CC     = gcc
CFLAGS = -O2 -Wall

% : %.c
	@/bin/rm -f $@
	$(CC) -o $@ $(CFLAGS) $<

all: $(PROGRAMS)

# redundant stanza:
loader: loader.c
	$(CC) -o $@ $(CFLAGS) $<

clean:
	/bin/rm -f *.exe *.o $(PROGRAMS) *~ *.bak
