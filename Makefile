all: marca spar doc

marca::
	echo "You have to build marca from within quartus."

spar::
	cd spar && make

doc::
	cd doc && make

dist::
	tar -czvf marca.tar.gz vhdl/ sim/ spar/ \
			       quartus/marca.qpf quartus/marca.qsf \
			       quartus/marca.pin \
			       doc/isa.tex doc/implementation.tex \
			       doc/factorial.s doc/uart_reverse.s \
			       doc/marca.dia doc/marca.eps doc/marca.png \
			       doc/uart_sim.eps doc/uart_sim.png \
                               doc/Makefile \
                               Makefile gpl.txt \
                               --exclude '*~'

clean::
	make -C spar clean
	make -C doc clean