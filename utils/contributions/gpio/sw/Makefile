include ../support/Makefile.inc
drivers = ../drivers/libdrivers.a
cases = gpio-nocache gpio-icdc
common = ../support/libsupport.a ../support/except.o

all: $(cases)

gpio-nocache: gpio.o udelay.o ../support/reset-nocache.o $(common) $(drivers)
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) $(GCC_LIB_OPTS) -T ../support/orp.ld $? -o $@.or32
	$(OR32_TOOL_PREFIX)-objcopy -O binary $@.or32 $@.bin
	../utils/bin2hex $@.bin 1 -size_word > $@$(FLASH_MEM_HEX_FILE_SUFFIX).hex
	../utils/bin2vmem $@.bin > $@.vmem


gpio-icdc: gpio.o udelay.o ../support/reset-icdc.o $(common) $(drivers)
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) $(GCC_LIB_OPTS) -T ../support/orp.ld $? -o $@.or32
	$(OR32_TOOL_PREFIX)-objcopy -O binary $@.or32 $@.bin
	../utils/bin2hex $@.bin 1 -size_word > $@$(FLASH_MEM_HEX_FILE_SUFFIX).hex
	../utils/bin2vmem $@.bin > $@.vmem


gpio.o: gpio.c
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) $? -c -o $@

udelay.o: udelay.c
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) $? -c -o $@
