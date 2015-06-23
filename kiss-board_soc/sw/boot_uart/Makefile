#
#
#
CC		= or32-uclinux-gcc
CFLAGS		= -c -O2 -DIC=0 -DDC=0 -DDEBUG
#
LD		= or32-uclinux-ld
LDFLAGS		= -T boot_uart.ld
LDFLAGSS	= `or32-uclinux-gcc -print-libgcc-file-name`
#
OBJCOPY		= or32-uclinux-objcopy
OBJCOPYFLAGS	= --remove-section=.extbss -O binary
#
#
#
INCLUDES	=
LIBS		=
#
#
#
OBJS = \
	entry.o \
	boot_uart.o

#
#
#
TARGET		= boot_uart
#
#
#
all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) $(LIBS) -o $@.or32 $(LDFLAGSS)
	or32-uclinux-objcopy --remove-section=.extbss -O binary $@.or32 $@.or32.bin 
	or32-uclinux-objdump -t $@.or32 >$@.or32.symbol
	or32-uclinux-objdump -x $@.or32 >$@.or32.header
	or32-uclinux-objdump -s $@.or32 >$@.or32.contents
	or32-uclinux-objdump -D $@.or32 >$@.or32.S
	../utils/bin2hex $@.or32.bin > $@.or32.hex
	../utils/bin2uart $@.or32.bin > $@.or32.uart.v

.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) $<

.S.o:
	$(CC) $(CFLAGS) $(INCLUDES) $<

clean:
	rm -f *.o *.or32 *.log *.bin *.srec *.hex *.log stdout.txt *.stackdump *.or32 *.or32.*
