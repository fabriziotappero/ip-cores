#-- Bring toolchain config parameters from the common makefile -----------------
include ../common/makefile

# We'll run the simulation for long enough to complete the test
SIM_LENGTH = 400000

# FPGA Block RAM parameters (size in words)
BRAM_START = 0xbfc00000
CODE_BRAM_SIZE = 2048
# Simulated FLASH parameters (size in bytes)
FLASH_START = 0xb0000000
FLASH_SIZE = 4096
# External RAM parameters (size in 16-bit halfwords)
# This is the RAM size simulated by slite; set the same value so the execution
# logs match.
XRAM_SIZE = 2048
XRAM_START = 0x00000000
# Set to > 0 to initialize and enable the cache before running the tests
TEST_CACHE = 1

LFLAGS = -Ttext $(BRAM_START) -Tdata $(XRAM_START) -eentry -I elf32-big
LFLAGS_FLASH = -Ttext $(FLASH_START) -eflash_test -I elf32-big

OBJS = memtest.o

#-- Configuration --------------------------------------------------------------

# Set to !=0 to test execution from flash
# (Set to 0 if running on real HW on which you have no initialized FLASH)
EXEC_FLASH = 1

#-- Targets & rules ------------------------------------------------------------

#-- Main target -- build code for BRAM and FLASH
memtest:  memtest.code memtest.data flash.bin
	-@# This comment prevents triggering the default rule. Instead, make will
	-@# invoke our rules for the dependencies.

#-- Targets for main code to be run from BRAM

memtest.o: memtest.s
	$(AS) -defsym TEST_CACHE=$(TEST_CACHE) -defsym EXEC_FLASH=$(EXEC_FLASH) \
    -defsym XRAM_BASE=$(XRAM_START) -o memtest.o memtest.s
    
memtest.axf: memtest.o
	$(LD) $(LFLAGS) -Map memtest.map -s -N -o memtest.axf memtest.o
	-@$(DUMP) -I elf32-big --disassemble memtest.axf > memtest.lst

# Dump code and data to separate binaries (data binary will be empty but 
# TB2 needs it anyway)

memtest.code: memtest.axf
	$(COPY) -I elf32-big -j .text -j .rodata -O binary memtest.axf memtest.code
memtest.data: memtest.axf
	$(COPY) -I elf32-big -j .sbss -j .data -j .bss -O binary memtest.axf memtest.data

#-- Targets for code to be run from FLASH 

flash.o: flash.s
	$(AS) -defsym TEST_CACHE=$(TEST_CACHE) -defsym FLASH_BASE=$(FLASH_START) -o flash.o flash.s

flash.axf: flash.o
	$(LD) $(LFLAGS_FLASH) -Map flash.map -s -N -o flash.axf flash.o
	-@$(DUMP) -I elf32-big --disassemble flash.axf > flash.lst

flash.bin: flash.axf
	$(COPY) -I elf32-big -j .text -j .rodata -O binary flash.axf flash.bin

    
    
#-- Targets that build the synthesizable vhdl; meant for direct invocation -----
    
#-- Create VHDL package with data and parameters for simulation
sim: memtest demo
	$(VHDL_OBJ_PKG) --project="Memtest" \
		--package sim_params_pkg \
		--bin memtest.code --name obj_code --bram_size $(CODE_BRAM_SIZE) \
		--bin memtest.data --name sram_init --xram_size $(XRAM_SIZE) \
		--bin flash.bin --name prom_init --flash_size $(FLASH_SIZE) \
		--output $(TB_DIR)/sim_params_pkg.vhdl \
		-s $(SIM_LENGTH) --log_trigger=0xbfc00000 \


#-- Create VHDL package with data and parameters for syntesis 
demo: memtest
	$(VHDL_OBJ_PKG) --project="Memtest" \
		--package obj_code_pkg \
		--bin memtest.code --name obj_code --bram_size $(CODE_BRAM_SIZE) \
		--output $(DEMO_DIR)/../SoC/bootstrap_code_pkg.vhdl

    
#-- And now the usual housekeeping stuff ---------------------------------------

.PHONY: clean

clean:
	-$(RM) *.o *.obj *.map *.lst *.hex *.exe *.axf *.code *.data *.bin
