include ../support/Makefile.inc
cases = fir50-nocache fir50-icdc
common = ../support/libsupport.a ../support/except.o

all: $(cases)

fir50-nocache:   int2str.o fir50.o ../support/reset-nocache.o $(common)
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) $(GCC_LIB_OPTS) -T ../support/orp.ld $? -o $@.or32
	$(OR32_TOOL_PREFIX)-objcopy -O binary $@.or32 $@.bin
	../utils/bin2hex $@.bin 1 -size_word > $@$(FLASH_MEM_HEX_FILE_SUFFIX).hex
	../utils/bin2vmem $@.bin > $@.vmem


fir50-icdc:  int2str.o fir50.o ../support/reset-icdc.o
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) $(GCC_LIB_OPTS) -T ../support/orp.ld $? -o $@.or32 $(common)
	$(OR32_TOOL_PREFIX)-objcopy -O binary $@.or32 $@.bin
	../utils/bin2hex $@.bin 1 -size_word > $@$(FLASH_MEM_HEX_FILE_SUFFIX).hex
	../utils/bin2vmem $@.bin > $@.vmem


fir50.o: FIR50.c
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) $? -c -o $@




int2str.o: int2str.c
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) $? -c -o $@

