all: isa.ps.gz isa.pdf implementation.ps.gz implementation.pdf

EXTERN_DATA: factorial.s uart_reverse.s marca.eps marca.png uart_sim.eps uart_sim.png

%.dvi: %.tex $(EXTERN_DATA)
	latex $<
	latex $<

%.ps: %.dvi
	dvips $< -o $@

%.ps.gz: %.ps
	gzip -c < $< > $@

%.pdf: %.tex %.dvi
	pdflatex $<

clean:
	rm -f *.ps *.pdf *.dvi *.aux *.log