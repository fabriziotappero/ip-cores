arci = amd64
#crus = arm-linux-gnu-
intende_nom = sospesifada
intende_fix = lib$(intende_nom).a

radi = ../..

fonte = $(radi)
fonte_arci = $(radi)/arci/$(arci)/fonte
fonte_linux = $(radi)/linux
compilador_inclui = -I$(fonte_arci)/../inclui -I../linux

instala_curso = /usr/local/lib

compilador = $(crus)gcc

compilador_sinia = -Wall -Werror -std=c99 -O2 -c $(compilador_inclui)
#linker = ld

arcivador = $(crus)ar
arcivador_sinia = crus

asembledor_s = $(crus)as

asembledor_asm = yasm
asembledor_asm_sinia = -f elf64

ojetos_otra = 
ojetos = $(ojetos_otra)\
 memoria_nova.o memoria_crese.o memoria_libri.o memoria_move.o\
 $(fonte_arci)/memoria/memoria_copia.o\
 scrive_stdout.o\
 consola_leje_carater.o\
 
%.o : %.c
	@echo $(compilador) $^
	@$(compilador) $(compilador_sinia) -o $@ $<

%.o : %.s
	@echo $(asembledor_s) $^
	@$(asembledor_s) $(asembledor_s_sinia) -o $@	$<

%.o : %.asm
	@echo $(asembledor_asm) $^
	@$(asembledor_asm) $(asembledor_asm_sinia) -o $@	$<

$(intende_fix) : $(ojetos)
	@echo $(arcivador) $@
	@$(arcivador) $(arcivador_sinia) $@ $^

instala: $(intende_fix)
	@echo instala $(intende_fix)
	@cp $(intende_fix) $(instala_curso)

sutrae:
	@echo sutrae $(intende_fix)
	@-rm $(instala_curso)/$(intende_fix)

limpa:
#	@-rm $(intende_fix) $(ojetos)
	@-rm $(ojetos) $(intende_fix)

