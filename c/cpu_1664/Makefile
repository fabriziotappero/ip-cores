arci = amd64
#crus = arm-linux-gnu-
intende_fix = lib1664.a

radi = ../..

fonte = $(radi)
fonte_linux = $(radi)/linux
compilador_inclui = -I$(radi)/arci/$(arci)/inclui -I../linux -I../lista

instala_curso = /usr/local/lib

compilador_varia =
compilador = $(crus)gcc$(compilador_varia)

compilador_sinia = -Dimita -Wall -Werror -std=c99 -O2  -c $(compilador_inclui)
libs = -l1664 -llista -lsospesifada
arcivador = $(crus)ar
arcivador_sinia = crus

asembledor = $(crus)as
ojetos_otra = 
ojetos = $(ojetos_otra)\
 cpu_1664_nova.o cpu_1664_libri.o\
 cpu_1664__pasi.o cpu_1664__desifri.o\
 cpu_1664_imaje_ajunta__lista.o cpu_1664_imaje_ajunta__datos.o cpu_1664_reinisia.o\
 \
 cpu_1664_opera___.o\
 cpu_1664_opera__ajusta.o\
 cpu_1664_opera__rev.o\
 cpu_1664_opera__yli.o cpu_1664_opera__ylr.o cpu_1664_opera__dep.o\
 cpu_1664_opera__stb.o cpu_1664_opera__ldb.o cpu_1664_opera__cmp.o\
 cpu_1664_opera__stm.o cpu_1664_opera__ldm.o cpu_1664_opera__ldi.o cpu_1664_opera__ldis.o\
 cpu_1664_opera__str.o cpu_1664_opera__ldr.o cpu_1664_opera__cam.o\
 cpu_1664_opera__and.o cpu_1664_opera__or.o cpu_1664_opera__eor.o\
 cpu_1664_opera__sar.o cpu_1664_opera__shr.o cpu_1664_opera__shl.o\
 cpu_1664_opera__plu.o cpu_1664_opera__sut.o cpu_1664_opera__sutr.o\
 cpu_1664_opera__mul.o cpu_1664_opera__div.o\
 cpu_1664_opera__bit.o\
 cpu_1664_vantaje.o cpu_1664_eseta.o\
 cpu_1664_umm.o cpu_1664_umm_tradui_desloca.o\
 \
 cpu_1664_asm_asm_comanda_ajunta.o\
 cpu_1664_asm_ajunta__cadena.o cpu_1664_asm_ajunta__ccadena.o\
 cpu_1664_asm_asm_comanda.o\
 cpu_1664_asm_asm_comanda__model.o cpu_1664_asm_asm_comanda__m.o\
 cpu_1664_asm_asm_model__lista.o\
 cpu_1664_asm_asm_comanda__opera.o cpu_1664_asm_asm_comanda__ajusta.o\
 cpu_1664_asm_asm_comanda__implicada.o\
 cpu_1664_asm_asm_comanda__defina.o cpu_1664_asm_asm_comanda__inclui.o\
 cpu_1664_asm_asm_comanda__nodefina.o\
 cpu_1664_asm_asm_comanda__ds.o cpu_1664_asm_asm_comanda__d4.o \
 cpu_1664_asm_asm_comanda__d2.o\
 cpu_1664_asm_asm_comanda__do.o cpu_1664_asm_asm_comanda__d1.o\
 cpu_1664_asm_lista_parametre__cadena.o\
 cpu_1664_asm_n8_valua__lista.o\
 cpu_1664_asm_n1_opera_valua__lista.o cpu_1664_asm_n8_valua__cadena.o\
 cpu_1664_asm_asm_opera__lista_2.o cpu_1664_asm_asm_opera__cadena.o\
 cpu_1664_asm_defina_valua.o\
 cpu_1664_asm_opera_parametre_funsiona_ajunta.o\
 cpu_1664_asm_taxe_d_ajunta.o\
 cpu_1664_asm_opera_parametre_funsiona__m.o\
 cpu_1664_asm_opera_parametre_funsiona__8e.o\
 cpu_1664_asm_opera_parametre_funsiona__8y.o\
 cpu_1664_asm_opera_parametre_funsiona__8ylr.o\
 cpu_1664_asm_opera_parametre_funsiona__2r6r.o\
 cpu_1664_asm_opera_parametre_funsiona__6r2r.o\
 cpu_1664_asm_opera_parametre_funsiona__3e3e2e.o\
 \
 cpu_1664_dev_dev.o cpu_1664_dev_dev_libri.o\
 cpu_1664_dev_opera_parametre_funsiona__m.o\
 cpu_1664_dev_opera_parametre_funsiona__8e.o\
 cpu_1664_dev_opera_parametre_funsiona__8y.o\
 cpu_1664_dev_opera_parametre_funsiona__8ylr.o\
 cpu_1664_dev_opera_parametre_funsiona__2r6r.o\
 cpu_1664_dev_opera_parametre_funsiona__6r2r.o\
 cpu_1664_dev_opera_parametre_funsiona__3e3e2e.o\
 cpu_1664_dev_opera_parametre_funsiona__nd.o\
\
\
 cpu_1664_opera__imita.o
 
%.o : %.c
	@echo $(compilador) $^
	@$(compilador) $(compilador_sinia) -o $@ $<

%.o : %.s
	@echo $(asembledor) $^
	@$(asembledor) $(asembledor_sinia) -o $@	$<

$(intende_fix) : $(ojetos)
	@echo $(arcivador) $@
	@$(arcivador) $(arcivador_sinia) $@ $^

1664: 1664.o
	@g++ $< -O2 $(libs) -s -o $@

instala: $(intende_fix)
	@echo instala $(intende_fix)
	@cp $(intende_fix) $(instala_curso)

sutrae:
	@echo sutrae $(intende_fix)
	@-rm $(instala_curso)/$(intende_fix)

limpa:
	@-rm $(ojetos) $(intende_fix)