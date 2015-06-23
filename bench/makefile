
PROJ_NAME ?= decrypt
DEBUG     ?= y

MODELSIM_DIR?=/opt/modeltech/modeltech
#MODELSIM_DIR=/mnt/new_disk/tool/modeltech/modeltech

ifeq ($(DEBUG),y)
CFLAGS=-DDEBUG
else
CFLAGS=
endif

all:csa_pli_modelsim


csa_pli_modelsim:csa_pli.sl

%.sl:%.o
	ld -shared -E -o $@ $^
	rm -fr csa_pli.o

%.o:%.c
	gcc -c -g -I$(MODELSIM_DIR)/include $^

test:csa_pli.vpi 

clean:
	rm -fr *.o *.vvp *.vpi *.log *.key *.sl

