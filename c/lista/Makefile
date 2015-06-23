arci = amd64
#crus = arm-linux-gnu-
intende_nom = lista
intende_fix = lib$(intende_nom).a

radi = ../..

fonte = $(radi)
fonte_linux = $(radi)/linux
compilador_inclui = -I$(radi)/arci/$(arci)/inclui -I../linux

instala_curso = /usr/local/lib

compilador_varia =
compilador = $(crus)gcc$(compilador_varia)

compilador_sinia = -Wall -Werror -std=c99 -O2 -c $(compilador_inclui)
#linker = ld

arcivador = $(crus)ar
arcivador_sinia = crus

asembledor = $(crus)as

ojetos_otra = n1__asciiexadesimal.o n4__asciiexadesimal.o n4__ccadenaexadesimal.o\
 n4_sinia__ccadena.o n4_sinia__cadena.o n8_sinia__cadena.o n8_sinia__ccadena.o\
 nN_cuantia__ccadena.o nN_sinia__ccadena.o nN_sinia__cadena.o nN_sinia__lista.o\
 fl2__cadena.o fl2__cadena_desimal.o fl2_frato__cadena.o\
 nN_cuantia_brasetida__cadena.o\
 nN__desimal_cadena.o n8__desimal_cadena.o\
 nN__exadesimal_cadena.o n8__exadesimal_cadena.o\
 nM_SPR__cadena.o\
 nN_trova__asende_n4.o n8_trova__asende_n8.o\
 asciidesimal__nN.o asciidesimal__n8.o\
 asciiexadesimal__nN.o asciiexadesimal__n8.o\
 \
 lista_ajunta_asciiexadesimal__cadena.o\
 lista_ajunta_asciiexadesimal__n8.o lista_ajunta_asciiexadesimal__n2.o\
 lista_ajunta_asciiexadesimal__n1.o\
 cadena__f.o\
 \
 cadena_asciidesimal__nN.o\
 cadena_ANSI__atribuida.o cadena_ANSI__2atribuida.o cadena_ANSI__3atribuida.o\
 cadena_ANSI__cursor_posa.o\
 cadena_ANSI_limpa.o\
 cadena_ANSI__cursor_sinistra.o cadena_ANSI__cursor_destra.o\
 cadena_ANSI__cursor_asende.o cadena_ANSI__cursor_desende.o\
 cadena_ANSI_cursor_orijin.o cadena_ANSI_cursor_posa_fisa.o cadena_ANSI_cursor_posa_restora.o\
 
ojetos = $(ojetos_otra)\
 lista_nova.o lista_nova__lista.o lista_nova__datos.o lista_nova__ccadena.o\
 lista_nova__crese.o\
 lista_libri.o lista_2_libri.o lista_2_nova__lista_2.o\
 lista_crese.o lista_inserta_capasia.o\
 lista_defini__crese.o\
 lista_ajunta__dato.o lista_ajunta__datos.o lista_ajunta__lista.o\
 lista_ajunta__P.o lista_ajunta__nN.o lista_ajunta__n2.o\
 lista_ajunta__n4.o lista_ajunta__n8.o lista_ajunta__fl2.o\
 lista_inserta__dato.o lista_inserta__datos.o lista_inserta__lista.o lista_inserta__P.o\
 lista_inserta__n4.o\
 lista_ajunta__ccadena.o \
 lista_inserta__ccadena.o \
 lista_dato_final.o lista_datos_final.o lista_P_final.o\
 lista_repone__dato.o lista_repone__datos.o\
 lista_sutrae__datos.o\
 
%.o : %.c
	@echo $(compilador) $^
	@$(compilador) $(compilador_sinia) -o $@ $<

%.o : %.s
	@echo $(asembledor) $^
	@$(asembledor) $(asembledor_sinia) -o $@	$<

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
	@-rm $(intende_fix) $(ojetos)
