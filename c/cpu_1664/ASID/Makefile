arci = amd64
#crus = arm-linux-gnu-
intende_fix = 1664

radi = ../../..

fonte = $(radi)/c
compilador_inclui = -I$(radi)/arci/$(arci)/inclui -I$(fonte)/cpu_1664 -I$(fonte)/linux -I$(fonte)/lista 

instala_curso = /usr/local/bin

compilador_varia =
compilador = $(crus)gcc$(compilador_varia)

compilador_sinia = -Dimita -Wall -Werror -std=c99 -O2  -c $(compilador_inclui)
libs = -l1664 -llista -lsospesifada

ojetos = 1664.o
 
%.o : %.c
	@echo $(compilador) $^
	@$(compilador) $(compilador_sinia) -o $@ $<

$(intende_fix): $(ojetos)
	@g++ $< -O2 $(libs) -s -o $@

instala: $(intende_fix)
	@echo instala $(intende_fix)
	@cp $(intende_fix) $(instala_curso)

sutrae:
	@echo sutrae $(intende_fix)
	@-rm $(instala_curso)/$(intende_fix)

limpa:
	@-rm $(ojetos) $(intende_fix)