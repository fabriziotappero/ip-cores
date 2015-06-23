#-- Bring toolchain config parameters from the common makefile
include ../common/makefile

# Link script to be used: run from BRAM
LINK_SCRIPT = $(SRC_DIR)/common/bram.lds

#-- Configure the application --------------------------------------------------

# Simulation length in cycles; long enough to let the program run to completion.
SIM_LENGTH = 90000

# FPGA Block RAM parameters
BRAM_START = 0xbfc00000
CODE_BRAM_SIZE = 2048
# External RAM parameters (size in words)
XRAM_SIZE = 1024
XRAM_START = 0x00000000


# 1.- Put the code in internal BRAM and the data in external SRAM.
# 2.- Do not use any of the standard libraries and use libsoc instead.

LFLAGS = -T$(LINK_SCRIPT) -L $(LIB_PATH) \
         -Ttext $(BRAM_START) -Tdata $(XRAM_START) \
         -nodefaultlibs -nostdlib -ereset -I elf32-big
CFLAGS = -O2 -Wall -c -s -fno-builtin -nodefaultlibs -nostdlib \
         -msoft-float -mips1 -G0
AFLAGS = --defsym XRAM_BASE=$(XRAM_START)


OBJS = bootstrap.o opcode_emu.o c_startup.o hello.o


#-- Targets & rules ------------------------------------------------------------

hello: hello.code hello.data
	@# This comment prevents use of implicit rule so our rules are used instead.
	@# This will save us a few harmless linker warnings.

hello.axf: $(OBJS)
	$(LD) $(LFLAGS) -Map hello.map -s -N -o hello.axf $(OBJS) -lsoc
	-@$(DUMP) -m mips --disassemble hello.axf > hello.lst

hello.code: hello.axf
# Extract object code to be placed in code space
	$(COPY) -I elf32-big -O binary hello.axf hello.code

hello.data: hello.axf
# Extract object code to be placed in data space
	$(COPY) -I elf32-big -j.data -j.bss -O binary hello.axf hello.data



bootstrap.o: $(SRC_DIR)/common/bootstrap.s
	$(AS) $(AFLAGS) -o bootstrap.o $(SRC_DIR)/common/bootstrap.s

c_startup.o: $(SRC_DIR)/common/c_startup.s
	$(AS) $(AFLAGS) -o c_startup.o $(SRC_DIR)/common/c_startup.s

opcode_emu.o: $(SRC_DIR)/common/opcode_emu.s
	$(AS) $(AFLAGS) -o opcode_emu.o $(SRC_DIR)/common/opcode_emu.s

hello.o: hello.c
	$(CC) $(CFLAGS) -o hello.o hello.c



#-- Targets that build the synthesizable vhdl; meant for direct invocation -----

#-- Create VHDL package with data and parameters for simulation 
sim: hello demo
	$(VHDL_OBJ_PKG) --project="Hello World" \
		--package sim_params_pkg \
		--bin hello.code --name obj_code --bram_size $(CODE_BRAM_SIZE) \
		--bin hello.data --name sram_init --xram_size $(XRAM_SIZE)\
		--name prom_init --flash_size 0 \
		--output $(TB_DIR)/sim_params_pkg.vhdl \
		-s $(SIM_LENGTH) --log_trigger=0xbfc00000 \

#-- Create VHDL file for simulation test bench using TB0 template
#-- This will instantiate the CPU without any caches or memory controller and
#-- will run the program off of an initialized ROM connected to the code 
#-- interface.
#-- NOTE: This target has not been used in some time and may be broken. It's 
#-- here because it can still be useful in an emergency.
sim_bram: hello
	$(TO_VHDL) --code hello.code --data hello.data \
		--code_size $(CODE_BRAM_SIZE) --data_size $(XRAM_SIZE) \
		-s $(SIM_LENGTH) -v $(SRC_DIR)/mips_tb0_template.vhdl \
		-o $(TB_DIR)/mips_tb2.vhdl -e mips_tb2

#-- Create VHDL package with data and parameters for simulation and syntesis
demo: hello
	$(VHDL_OBJ_PKG) --project="Hello World" \
		--package obj_code_pkg \
		--bin hello.code --name obj_code --bram_size $(CODE_BRAM_SIZE) \
		--output $(DEMO_DIR)/../SoC/bootstrap_code_pkg.vhdl


#-- And now the usual housekeeping stuff ---------------------------------------

.PHONY: clean

clean:
	-$(RM) *.o *.obj *.map *.lst *.hex *.exe *.axf *.code *.data *.bin
