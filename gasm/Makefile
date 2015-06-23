#    This file is part of gasm.
#
#    
# If you encountered any problem, please contact :
#                                                 
#   lmouton@enserg.fr                             
#   shangoue@enserg.fr                            
#                                                 


# Makefile de type compilation du projet
#
# Cibles possibles :
#
# project, all, asmica	Compile l'assembleur avec main.c et tous les modules en les recompilant au besoin
# info			Informe sur l'état d'avancement du projet
# nom_module		Recompile le module indiqué
# menage		Fait le menage des fichiers generes
# exec			Executer le programme
# save[fichier_tar]	Archivage du projet dans sav/

COMP_OPT = -I$(INCLUDE_PATH) -O2 -Wall -ansi -pipe -s

# Repertoires du projet
# SOUS_REP est défini dans le Makefile appelant
LIB_PATH = lib
INCLUDE_PATH = include
SRC_PATH = src

# inclusion de la définition des dépendances
include Makefile.dep

VPATH = $(LIB_PATH) : $(INCLUDE_PATH) : $(SRC_PATH)

# modules du projet dans l'ordre des dépandances
MODS_OBJ = $(addsuffix .o, $(strip $(ALL)))
MODS_SRC = $(addsuffix .c, $(strip $(ALL)))

# Compilateur utilisé et options de compilation d'édition de liens
CC = gcc
LINK_OPT =

.SILENT : menage exec $(MODS_OBJ) info
.PHONY : all project exec menage

all project : asmips

asmips : main.c $(MODS_OBJ)
	$(CC) $(COMP_OPT) $(LINK_OPT) $< $(addprefix $(LIB_PATH)/, $(MODS_OBJ)) -o $@

$(MODS_OBJ) : %.o : %.c $(addsuffix .h, $(%_DEP))
	@echo Compilation du module $*
	$(CC) $(COMP_OPT) -o $(LIB_PATH)/$*.o -c $<

menage :
	@echo Menage des fichiers principaux du projet
	rm -f *.o
	rm -f core.*
	rm -f *~
	rm -f asmips
	rm -f a.obj a.lst
	rm -f $(LIB_PATH)/*.o

exec :
	$(MAKE) -s project
	clear
	./asmips

save[%] :
	@tar -jvcf ../sav/$*.tbz2 *

info :
	@echo Modules installés :
	ls $(LIB_PATH)

