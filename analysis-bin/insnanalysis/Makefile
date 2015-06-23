
APP=insnanalysis

CFLAGS ?= -O2

all: $(APP)

SRC=insnanalysis.c or1k-32-insn.c  insn-lists.c
HDRS=insnanalysis.h or1k-32-insn.h insn-lists.h


insnanalysis:  $(SRC) $(HDRS)
	gcc $(CFLAGS) $(SRC) -o $@


test: test.bin $(APP)
	./$(APP) -f $<
	./$(APP) -f $< -o /dev/null

test.bin: test.o
	or32-elf-objcopy -O binary $< $@

test.o: test.S
	or32-elf-as $< -o $@

clean:
	rm -f $(APP) *.o *.bin
