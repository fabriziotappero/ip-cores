TEX=hpdmc.tex

DVI=$(TEX:.tex=.dvi)
PS=$(TEX:.tex=.ps)
PDF=$(TEX:.tex=.pdf)
AUX=$(TEX:.tex=.aux)
LOG=$(TEX:.tex=.log)

all: $(PDF)

%.dvi: %.tex
	latex $<

%.ps: %.dvi
	dvips $<

%.pdf: %.ps
	ps2pdf $<

clean:
	rm -f $(DVI) $(PS) $(PDF) $(AUX) $(LOG)

.PHONY: clean
