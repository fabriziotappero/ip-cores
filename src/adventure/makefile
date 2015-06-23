#-- Bring toolchain config parameters from the common makefile
include ../common/makefile

#-- Configure the VHDL simulation environment ----------------------------------

# Simulation length in cycles; long enough to let the program run to completion.
SIM_LENGTH = 400000000


#-- Configure the memory map ---------------------------------------------------
# FIXME this info is redundant with the linker script

# FPGA Block RAM parameters
BRAM_START = 0xbfc00000
CODE_BRAM_SIZE = 512
# External RAM parameters (size in words)
XRAM_SIZE = 200000 
XRAM_START = 0x00000000
# External FLASH parameters (size in words) 
# Note te size is for simulation only
FLASH_START = 0xb0000000 
FLASH_SIM_SIZE = 65536 

#-- Configure the code ---------------------------------------------------------

# Options for 'boot' code running from BRAM at 0xbfc00000:
# 1.- Put the code in internal BRAM and the data in external SRAM.
# 2.- Do not use any of the standard libraries and use libsoc instead.
LFLAGS_BOOT = -L $(LIB_PATH) -Ttext $(BRAM_START) -Tdata $(XRAM_START) \
         -nodefaultlibs -nostdlib -ereset -I elf32-big -defsym entry=$(FLASH_START)
CFLAGS_BOOT = -O2 -Wall -c -s -fno-builtin -nodefaultlibs -nostdlib \
         -msoft-float -mips1 -G0
AFLAGS_BOOT = --defsym RUN_FROM_BRAM=1 --defsym XRAM_BASE=$(XRAM_START)


# Options for 'main' code running from FLASH at 0xb0000000:
# 1.- Put the code in FLASH and the data in external SRAM.
# 2.- Do not use any of the standard libraries and use libsoc instead.
LFLAGS_MAIN = -T$(LINK_SCRIPT) -L $(LIB_PATH) \
         -nodefaultlibs -nostdlib -eentry -I elf32-big
CFLAGS_MAIN = -O2 -Wall -c -s -fno-builtin -nodefaultlibs -nostdlib \
         -msoft-float -mips1 -G0
AFLAGS_MAIN = --defsym XRAM_BASE=$(XRAM_START)

# Options for 'main' code running from XRAM at 0x00000000:
# 1.- Put the code and the data in external XRAM.
# 2.- Do not use any of the standard libraries and use libsoc instead.
LINK_SCRIPT_XRAM=$(SRC_DIR)/common/xram.lds
LFLAGS_SD = -T$(LINK_SCRIPT_XRAM) -L $(LIB_PATH) \
         -nodefaultlibs -nostdlib -eentry -I elf32-big


# Object files for main program
OBJS = c_startup.o main.o actions1.o actions2.o init.o misc.o \
        score.o adv_baremetal.o
SRCS = actions1.c actions2.c main.c init.c misc.c score.c adv_baremetal.c


#-- Targets & rules ------------------------------------------------------------

# Use this target to make a 'bootloadable' binary of adventure as 'code.bin'.
# You can then boot this file from an SD card using the sdboot demo bootloader.
sd: code.bin
	@# This comment prevents use of implicit rule so our rules are used instead.
	@# This will save us a few harmless linker warnings.

code.bin: code.axf
    # Extract object code to be placed in code space
	$(COPY) -I elf32-big -O binary code.axf code.bin

code.axf: $(OBJS)
	$(LD) $(LFLAGS_SD) -Map adventure.map -s -N -o code.axf $(OBJS) -lsoc
	-@$(DUMP) -m mips --disassemble adventure.axf > adventure.lst
    
    
adventure: adventure.bin bootstrap
	@# This comment prevents use of implicit rule so our rules are used instead.
	@# This will save us a few harmless linker warnings.

adventure.bin: adventure.axf
	# Extract object code to be placed in code space
	$(COPY) -I elf32-big -O binary adventure.axf adventure.bin
    
adventure.axf: $(OBJS)
	$(LD) $(LFLAGS_MAIN) -Map adventure.map -s -N -o adventure.axf $(OBJS) -lsoc
	-@$(DUMP) -m mips --disassemble adventure.axf > adventure.lst

c_startup.o: $(SRC_DIR)/common/c_startup.s
	$(AS) $(AFLAGS_MAIN) -o c_startup.o $(SRC_DIR)/common/c_startup.s


actions1.o:         misc.h main.h share.h funcs.h
main.o:             misc.h adv_baremetal.h
actions2.o:         misc.h main.h share.h funcs.h
init.o:             misc.h main.h share.h funcs.h
misc.o:             misc.h main.h
score.o:            misc.h main.h share.h
adv_baremetal.o:    adv_baremetal.h


#-- Compilation of 'boot' code to be run from BRAM

bootstrap.o: $(SRC_DIR)/common/bootstrap.s
	$(AS) -defsym XRAM_BASE=$(XRAM_START) -o bootstrap.o $(SRC_DIR)/common/bootstrap.s

opcode_emu.o: $(SRC_DIR)/common/opcode_emu.s
	$(AS) $(AFLAGS) -o opcode_emu.o $(SRC_DIR)/common/opcode_emu.s

bootstrap.axf: bootstrap.o opcode_emu.o
	$(LD) $(LFLAGS_BOOT) -Map bootstrap.map -s -N -o bootstrap.axf bootstrap.o opcode_emu.o
	-@$(DUMP) -I elf32-big --disassemble bootstrap.axf > bootstrap.lst

bootstrap: bootstrap.axf
	$(COPY) -I elf32-big -j .text -j .rodata -O binary bootstrap.axf bootstrap.code
	$(COPY) -I elf32-big -j .sbss -j .data -j .bss -O binary bootstrap.axf bootstrap.data

    
#-- Let's make some implicit rules explicit for clarity (well, 'clarity')

%.o: %.c
	$(CC) $(CFLAGS_MAIN) $< -o $@


#-- Targets that build the synthesizable vhdl; meant for direct invocation -----



#-- Create VHDL package with data and parameters for simulation
sim: bootstrap adventure demo
	$(VHDL_OBJ_PKG) --project="Adventure" \
		--package sim_params_pkg \
		--bin bootstrap.code --name obj_code --bram_size $(CODE_BRAM_SIZE) \
		--name sram_init --xram_size $(XRAM_SIZE) \
		--bin adventure.bin --name prom_init --flash_size $(FLASH_SIM_SIZE) \
		--output $(TB_DIR)/sim_params_pkg.vhdl \
		-s $(SIM_LENGTH) --log_trigger=0xb0000000 \


# Create VHDL file for hardware demo
demo: bootstrap adventure
	$(VHDL_OBJ_PKG) --project="Adventure" \
		--package obj_code_pkg \
		--bin bootstrap.code --name obj_code \
		--output $(DEMO_DIR)/../SoC/bootstrap_code_pkg.vhdl


#-- And now the usual housekeeping stuff ---------------------------------------

.PHONY: clean

clean:
	-$(RM) *.o *.obj *.map *.lst *.hex *.exe *.axf *.code *.data *.bin