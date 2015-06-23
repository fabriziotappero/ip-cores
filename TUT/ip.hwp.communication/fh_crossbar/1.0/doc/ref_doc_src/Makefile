#
# Makefile for ref_doc.tex
#


ref_doc: ref_doc.pdf


ref_doc.pdf: ref_doc.tex
	pdflatex ref_doc.tex
	pdflatex ref_doc.tex
	pdflatex ref_doc.tex

.PHONY: clean
clean:
	rm -f *.aux ref_doc.pdf *.log *.toc *~
