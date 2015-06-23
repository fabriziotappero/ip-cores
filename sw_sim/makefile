
PROJ_NAME ?= group_decrypt
DEBUG ?=y

CFLAGS=-g -ggdb -ansi -Wall

ifeq ($(DEBUG),y)
CFLAGS+=-DDEBUG
endif

all:$(PROJ_NAME)

clean:
	rm -fr $(PROJ_NAME)
	rm -fr *.o

tt:$(PROJ_NAME)
	./$(PROJ_NAME) <../test_dat/$(PROJ_NAME).in >../test_dat/$(PROJ_NAME).out.sw

dd:$(PROJ_NAME)
	echo "set args <../test_dat/$(PROJ_NAME).in >../test_dat/$(PROJ_NAME).out.sw " >gdb-command
	ddd ./$(PROJ_NAME) -x gdb-command
        

key_perm:csa.o key_perm.o

key_schedule:csa.o key_schedule.o

block_decypher:csa.o block_decypher.o

decrypt:csa.o decrypt.o

stream_cypher:csa.o stream_cypher.o

group_decrypt:csa.o group_decrypt.o

-include .depend

CSRCS=                           \
        block_decypher.c         \
        csa.c decrypt.c          \
        get_key_perm_table.c     \
        key_perm.c               \
        key_schedule.c           \
        misc.c                   \
        stream_cypher.c

depend:
	rm -fr .depend        	
	for f in $(CSRCS);              \
        do                              \
                gcc -M -MM $$f>>.depend;\
        done
