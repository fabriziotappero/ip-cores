#
# Compiles the Tex source and pdf figures
#
# Erno salminen, April 2012
#

FIGS = fig/app_interface.pdf fig/data_example.pdf fig/eth_interface.pdf \
	fig/eth_timing.pdf fig/header_states.pdf fig/receiving.pdf \
	fig/sending.pdf fig/system_overview.pdf fig/tx_timing.pdf \
	fig/udp_block_states.pdf

all: udp_ip_datasheet.pdf

udp_ip_datasheet.pdf: udp_ip_datasheet.tex $(FIGS)
	pdflatex udp_ip_datasheet.tex
	pdflatex udp_ip_datasheet.tex


clean:
	rm udp_ip_datasheet.toc
	rm udp_ip_datasheet.aux
	rm udp_ip_datasheet.log
