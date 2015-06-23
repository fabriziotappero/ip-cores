#
#   Makefile for MMIXware
#

#   Be sure that CWEB version 3.0 or greater is installed before proceeding!
#   In fact, CWEB 3.61 is recommended for making hardcopy or PDF documentation.

#   If you prefer optimization to debugging, change -g to something like -O:
CFLAGS = -g

#   Uncomment the second line if you use pdftex to bypass .dvi files:
PDFTEX = dvipdfm
#PDFTEX = pdftex

.SUFFIXES: .dvi .tex .w .ps .pdf .mmo .mmb .mms

.tex.dvi:
	tex $*.tex

.dvi.ps:
	dvips $* -o $*.ps

.w.c:
	if test -r $*.ch; then ctangle $*.w $*.ch; else ctangle $*.w; fi

.w.tex:
	if test -r $*.ch; then cweave $*.w $*.ch; else cweave $*.w; fi

.w.o:
	make $*.c
	make $*.o

.w:
	make $*.c
	make $*

.w.dvi:
	make $*.tex
	make $*.dvi

.w.ps:
	make $*.dvi
	make $*.ps

.w.pdf:
	make $*.tex
	case "$(PDFTEX)" in \
	 dvipdfm ) tex "\let\pdf+ \input $*"; dvipdfm $* ;; \
	 pdftex ) pdftex $* ;; \
	esac

.mmo.mmb:
	mmix -D$*.mmb $*.mmo

.mms.mmo:
	mmixal -x -b 250 -l $*.mml $*.mms

WEBFILES = abstime.w boilerplate.w mmix-arith.w mmix-config.w mmix-doc.w \
	mmix-io.w mmix-mem.w mmix-pipe.w mmix-sim.w mmixal.w mmmix.w mmotype.w
CHANGEFILES =
TESTFILES = *.mms silly.run silly.out *.mmconfig *.mmix
MISCFILES = Makefile makefile.dos README mmix.mp mmix.1
ALL = $(WEBFILES) $(TESTFILES) $(MISCFILES)

basic:  mmixal mmix

doc:    mmix-doc.ps mmixal.dvi mmix-sim.dvi
	dvips -n13 mmixal.dvi -o mmixal-intro.ps
	dvips -n8 mmix-sim.dvi -o mmix-sim-intro.ps

all:    mmixal mmix mmotype mmmix

clean:
	rm -f *~ *.o *.c *.h *.tex *.log *.dvi *.toc *.idx *.scn *.ps core

mmix-pipe.o: mmix-pipe.c abstime
	./abstime > abstime.h
	$(CC) $(CFLAGS) -c mmix-pipe.c
	rm abstime.h

mmix-config.o: mmix-pipe.o

mmmix:  mmix-arith.o mmix-pipe.o mmix-config.o mmix-mem.o mmix-io.o mmmix.c
	$(CC) $(CFLAGS) mmmix.c \
	  mmix-arith.o mmix-pipe.o mmix-config.o mmix-mem.o mmix-io.o -o mmmix

mmixal: mmix-arith.o mmixal.c
	$(CC) $(CFLAGS) mmixal.c mmix-arith.o -o mmixal

mmix:   mmix-arith.o mmix-io.o mmix-sim.c abstime
	./abstime > abstime.h
	$(CC) $(CFLAGS) mmix-sim.c mmix-arith.o mmix-io.o -o mmix
	rm abstime.h

tarfile: $(ALL)
	tar cvf /tmp/mmix.tar $(ALL)
	gzip -9 /tmp/mmix.tar
