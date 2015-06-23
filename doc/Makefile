# $Id: Makefile,v 1.1.1.1 2005-11-15 01:51:52 arif_endro Exp $
#

MAIN_TEX_SOURCE = product_code_iterative_decoder
DVIPS_OPTIONS   = -Pams -Pamz -Pcm -Pcmz 

all            : $(MAIN_TEX_SOURCE).dvi

%.dvi          : %.tex
	latex $<

%.ps           : %.dvi
	dvips $(DVIPS_OPTIONS) -f $< -o $@ 

%.pdf          : %.ps
	ps2pdf13 -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 $<

dvi            : $(MAIN_TEX_SOURCE).dvi
ps             : $(MAIN_TEX_SOURCE).ps
pdf            : $(MAIN_TEX_SOURCE).pdf

clean          :
	rm -v -f *.log *.aux *.toc *.lot *.lof *.out

real_clean     : clean
	rm -v -f $(MAIN_TEX_SOURCE).ps $(MAIN_TEX_SOURCE).dvi $(MAIN_TEX_SOURCE).pdf 
