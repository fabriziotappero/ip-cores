#########################
# configuration section #
#########################

ZTEXPREFIX=../..

#PREFIX  base directory for installing 
#default: /usr/local for OS=UNIX and c:\usr else
#e.g. PREFIX=/usr

#JAVADIR  where to install jar's
#default: $(PREFIX)/share/java

#BINDIR  where to install bin's
#default: $(PREFIX)/bin

#MANDIR  where to install mans's
#default: $(PREFIX)/share/man/man1

################################
# DO NOT CHANAGE THE FOLLOWING #
################################

.PHONY: all clean distclean install


JAVAC=javac
INSTALL=install
INSTALLDIR=$(INSTALL) -d 
INSTALLEXE=$(INSTALL) -m 0755
INSTALLFILE=$(INSTALL) -m 0644

CLASSPATH:=.:$(ZTEXPREFIX)/libusbJava:$(ZTEXPREFIX)/java:/usr/local/share/java:/usr/share/java:$(CLASSPATH)
JAVAFILES:=$(wildcard *.java)

ifndef PREFIX
  PREFIX=/usr/local
endif

ifndef JAVADIR
  JAVADIR=$(PREFIX)/share/java
endif

ifndef BINDIR
  BINDIR=$(DESTDIR)$(PREFIX)/bin
endif

all : $(JAVAFILES)
	$(JAVAC) -cp "$(CLASSPATH)" $(JAVAFILES)

install: $(CLASSTARGETS)
	$(INSTALLDIR) $(JAVADIR)/ztex
	$(INSTALLFILE) *.class $(JAVADIR)/ztex

clean: 
	rm -f *~ *.bak *.old

distclean: clean
	rm -f $(JARTARGET)
	rm -f *.class
