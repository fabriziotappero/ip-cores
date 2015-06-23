CC	= iverilog
SIM = vvp

CFLAGS =-Wall -Irtl/

vpath %.v rtl tb
vpath %.vh rtl

FIFO			= fifo.v \
						generic_dpram.v
CONST_ENC	= $(FIFO) \
						const_enc.v



.PHONY: all sim doc clean

all: sim


sim: fifo const_enc


const_enc: const_enc.vvp
	@echo -e "\n--> Simulating $@"
	$(SIM) $^

const_enc.vvp: tb_const_enc.v const_map_data.v $(CONST_ENC)
	$(CC) $(CFLAGS) $^ -s tb_const_encoder -o $@

fifo: fifo.vvp
	@echo -e "\n--> Simulating $@"
	$(SIM) $^
	
fifo.vvp: tb_fifo.v $(FIFO)
	@echo -e "\n--> Compiling $@"
	$(CC) $(CFLAGS) $^ -s tb_fifo -o $@

doc:
	$(MAKE) -C doc/


clean:
	rm -f *.vvp
	$(MAKE) -C doc/ cleantex
