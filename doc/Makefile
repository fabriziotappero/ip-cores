all:	gpl-3.0.pdf spec.pdf
DSRC := src

gpl-3.0.pdf: $(DSRC)/gpl-3.0.tex
	latex $(DSRC)/gpl-3.0.tex
	latex $(DSRC)/gpl-3.0.tex
	dvips -q -z -t letter -P pdf -o gpl-3.0.ps gpl-3.0.dvi
	ps2pdf -dAutoRotatePages=/All gpl-3.0.ps gpl-3.0.pdf
	rm gpl-3.0.dvi gpl-3.0.log gpl-3.0.aux gpl-3.0.ps

spec.pdf: $(DSRC)/spec.tex $(DSRC)/gqtekspec.cls $(DSRC)/GT.eps
	cd $(DSRC)/; latex spec.tex
	cd $(DSRC)/; latex spec.tex
	dvips -q -z -t letter -P pdf -o spec.ps $(DSRC)/spec.dvi
	ps2pdf -dAutoRotatePages=/All spec.ps spec.pdf
	rm $(DSRC)/spec.dvi $(DSRC)/spec.log
	rm $(DSRC)/spec.aux $(DSRC)/spec.toc
	rm $(DSRC)/spec.lot # $(DSRC)/spec.lof
	rm spec.ps

