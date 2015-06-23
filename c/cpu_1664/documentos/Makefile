intende_fix = 1664
 
pdf: $(intende_fix).tex
	@echo "LaTeX -> PDF"
	@-rm $(intende_fix).pdf
	@latex $^
	@latex -output-format=pdf $^

limpa:
	@-rm $(intende_fix).aux $(intende_fix).pdf $(intende_fix).dvi $(intende_fix).log $(intende_fix).toc