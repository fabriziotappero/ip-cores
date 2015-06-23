#
# Compiles the Tex source and pdf figures
#




all: dm9ka_controller.pdf

dm9ka_controller.pdf: dm9ka_controller.tex modules.pdf read_module_states.pdf send_module_states.pdf
	pdflatex dm9ka_controller.tex
#	pdflatex dm9ka_controller.tex

clean:
	rm dm9ka_controller.toc
	rm dm9ka_controller.aux
	rm dm9ka_controller.log
