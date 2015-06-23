INSTALL_LOCATION=/usr/local

.c.o :
	cc -I . -c $<

all: gecko3-util

gecko3-util: gecko3-util.o
	cc -o $@ gecko3-util.o -L. -lusb

install: gecko3-util-install

gecko3-util-install:
	mkdir -p $(INSTALL_LOCATION)/bin
	cp gecko3-util $(INSTALL_LOCATION)/bin
	chmod 755 $(INSTALL_LOCATION)/bin/gecko3-util

clean:
	rm -f *.o gecko3-util

