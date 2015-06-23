#
# Makefile for ECO32 manual
#

BUILD = ../../build

SRCS = architecture.tex demosoc.tex eco32.tex impl.tex intro.tex mybib.tex \
       ownsoc.tex signals.pdf signals.svg signals.tex toolchain.tex \
       isa/comp.tex isa/isa.tex isa/jump.tex isa/ldst.tex isa/system.tex

.PHONY:		all install clean

all:		eco32.pdf

install:	eco32.pdf
		mkdir -p $(BUILD)/doc
		cp eco32.pdf $(BUILD)/doc

eco32.pdf:	$(SRCS)
		pdflatex eco32.tex
		pdflatex eco32.tex
		pdflatex eco32.tex

clean:
		rm -f eco32.aux eco32.log eco32.out eco32.pdf eco32.toc
		rm -f isa/*~ *~
