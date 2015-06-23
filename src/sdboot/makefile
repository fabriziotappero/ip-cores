#-- Bring toolchain config parameters from the common makefile
include ../common/makefile

# Link script to be used: run from BRAM, use upper chunk of RAM, leaving 
# the memory from 0x0 onwards free to be initialized with the binary file
# read from the SD card.
LINK_SCRIPT = $(SRC_DIR)/common/boot.lds

#-- Configure the application --------------------------------------------------

# Simulation length in cycles; long enough to let the program run to completion.
SIM_LENGTH = 90000

# FPGA Block RAM parameters (size in words)
# 16K is far too much BRAM; in a real world the bootloader would have to be
# squeezed into a smaller space or placed in flash. For our purposes this 
# will do.
BRAM_START = 0xbfc00000
CODE_BRAM_SIZE = 4096
# External RAM parameters (size in words)
# We're using the top 16K of the main 512K RAM area; the rest will be filled 
# with the code read from disk.
XRAM_SIZE = 4096
XRAM_START = 0x0007BFFC

# Here's where the FatFs source lives
FATFS = ../common/fatfs

# 1.- Put the code in internal BRAM and the data in external SRAM.
# 2.- Do not use any of the standard libraries and use libsoc instead.

LFLAGS = -T$(LINK_SCRIPT) -L $(LIB_PATH) \
         -Ttext $(BRAM_START) -Tdata $(XRAM_START) \
         -nodefaultlibs -nostdlib -ereset -I elf32-big
CFLAGS = -O2 -Wall -c -s -fno-builtin -nodefaultlibs -nostdlib \
         -msoft-float -mips1 -G0 -I $(FATFS)
AFLAGS = --defsym XRAM_BASE=$(XRAM_START)


OBJS = bootstrap.o opcode_emu.o c_startup.o sdboot.o \
       $(FATFS)/mmcbb.o $(FATFS)/ff.o
       


#-- Targets & rules ------------------------------------------------------------

sdboot: sdboot.code
	@# This comment prevents use of implicit rule so our rules are used instead.
	@# This will save us a few harmless linker warnings.

sdboot.axf: $(OBJS)
	$(LD) $(LFLAGS) -Map sdboot.map -s -N -o sdboot.axf $(OBJS) -lsoc
	-@$(DUMP) -m mips --disassemble sdboot.axf > sdboot.lst

sdboot.code: sdboot.axf
# Extract object code to be placed in code space
	$(COPY) -I elf32-big -O binary sdboot.axf sdboot.code


# Rules for the assembly source files
bootstrap.o: $(SRC_DIR)/common/bootstrap.s
	$(AS) $(AFLAGS) -o bootstrap.o $(SRC_DIR)/common/bootstrap.s

c_startup.o: $(SRC_DIR)/common/c_startup.s
	$(AS) $(AFLAGS) -o c_startup.o $(SRC_DIR)/common/c_startup.s

opcode_emu.o: $(SRC_DIR)/common/opcode_emu.s
	$(AS) $(AFLAGS) -o opcode_emu.o $(SRC_DIR)/common/opcode_emu.s

#-- Let's make some implicit rules explicit for clarity (well, 'clarity')

%.o: %.c
	$(CC) $(CFLAGS_MAIN) $< -o $@

    

#-- Targets that build the synthesizable vhdl; meant for direct invocation -----

#-- Create VHDL package with data and parameters for simulation 
sim: sdboot demo
	$(VHDL_OBJ_PKG) --project="SD Bootloader" \
		--package sim_params_pkg \
		--bin sdboot.code --name obj_code --bram_size $(CODE_BRAM_SIZE) \
		--name prom_init --flash_size 0 \
		--output $(TB_DIR)/sim_params_pkg.vhdl \
		-s $(SIM_LENGTH) --log_trigger=0xbfc00000 \

#-- Create VHDL package with data and parameters for simulation and syntesis
demo: sdboot
	$(VHDL_OBJ_PKG) --project="SD Bootloader" \
		--package obj_code_pkg \
		--bin sdboot.code --name obj_code --bram_size $(CODE_BRAM_SIZE) \
		--output $(DEMO_DIR)/../SoC/bootstrap_code_pkg.vhdl


#-- And now the usual housekeeping stuff ---------------------------------------

.PHONY: clean

clean:
	-$(RM) *.o *.obj *.map *.lst *.hex *.exe *.axf *.code *.data *.bin
	-$(RM) $(FATFS)/*.o
