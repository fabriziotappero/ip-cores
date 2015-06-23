# $Id: Makefile,v 1.3 2005-03-29 05:03:20 arif_endro Exp $

MYFILE = simple_fm_receiver

all            : docs clean

dvi   : $(MYFILE).tex
	latex $(MYFILE).tex

ps    : dvi
	dvips -f $(MYFILE).dvi -o $(MYFILE).ps 

pdf   : dvi
	dvipdf $(MYFILE).dvi

print : dvi
	dvips $(MYFILE).dvi

clean :
	rm -v -f *.log *.dvi *.aux *.toc *.lof

real_clean: clean
	rm -v -f $(MYFILE).ps $(MYFILE).pdf
