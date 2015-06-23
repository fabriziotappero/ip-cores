arci = x86
intende_nom = memoria
intende_fix = lib$(intende_nom).a

radi = ../../..

fonte = $(radi)
fonte_linux = $(radi)/linux
compilador_inclui = -I$(radi)/arci/$(arci)/inclui

instala_curso = /usr/local/lib

compilador = $(crus)gcc

compilador_sinia = -O2 -c $(compilador_inclui)

arcivador = $(crus)ar
arcivador_sinia = crus

asembledor_s = $(crus)as

asembledor_asm = yasm
asembledor_asm_sinia = -f elf32

ojetos_otra = 
ojetos = $(ojetos_otra)\
 memoria_copia.o
  
%.o : %.c
	@echo $(compilador) $^
	@$(compilador) $(compilador_sinia) -o $@ $<

%.o : %.s
	@echo $(asembledor_s) $^
	@$(asembledor) $(asembledor_s_sinia) -o $@	$<

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

