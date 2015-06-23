#
#
#
DATE		= "`date --rfc-2822`"
#
#
CC		= or32-uclinux-gcc

# slow
#CFLAGS		= -c -O2 -DBUILD_ID=\"$(DATE)\" -DDEBUG -msoft-mul -msoft-div -msoft-float
# fast
CFLAGS		= -c -O2 -DBUILD_ID=\"$(DATE)\" -DDEBUG -mhard-mul -msoft-div -msoft-float
##
## -mhard-div is NG (etc, /127 /126)
## -mhard-flat is NG (etc, 1.234 3.1415)
#
LD		= or32-uclinux-ld
LDFLAGS		= -T ld_boot_flash.ld
#
OBJCOPY		= or32-uclinux-objcopy
OBJCOPYFLAGS	= --remove-section=.extbss -O binary
#
INCLUDES	=
LIBS		= `or32-uclinux-gcc -print-libgcc-file-name`
#
OBJS		= support.o int.o tick.o timer.o uart.o dma.o screen.o font.o image.o vram.o debug.o syscall.o net.o main.o
#
OBJ1		= reset.noic.nodc.o
OBJ2		= reset.ic.nodc.o
OBJ3		= reset.noic.dc.o
OBJ4		= reset.ic.dc.o
#
TARGET1		= boot_flash.noic.nodc.or32
TARGET2		= boot_flash.ic.nodc.or32
TARGET3		= boot_flash.noic.dc.or32
TARGET4		= boot_flash.ic.dc.or32
#
#IC_SIZE		= 512
#DC_SIZE		= 512
IC_SIZE		= 4096
DC_SIZE		= 4096
#
#
#
all: $(TARGET1) $(TARGET2) $(TARGET3) $(TARGET4)

$(TARGET1): $(OBJS) $(OBJ1)
	$(LD) $(LDFLAGS) $(OBJ1) $(OBJS) $(LIBS) -o $@
	or32-uclinux-objcopy --remove-section=.extbss -O binary $@ $@.bin
	or32-uclinux-objdump -t $@ >$@.symbol
	or32-uclinux-objdump -x $@ >$@.header
	or32-uclinux-objdump -s $@ >$@.contents
	or32-uclinux-objdump -D $@ >$@.S
	../utils/bin2bin $@.bin > $@.bin.bin
	../utils/bin2hex $@.bin > $@.hex
$(TARGET2): $(OBJS) $(OBJ2)
	$(LD) $(LDFLAGS) $(OBJ2) $(OBJS) $(LIBS) -o $@
	or32-uclinux-objcopy --remove-section=.extbss -O binary $@ $@.bin
	or32-uclinux-objdump -t $@ >$@.symbol
	or32-uclinux-objdump -x $@ >$@.header
	or32-uclinux-objdump -s $@ >$@.contents
	or32-uclinux-objdump -D $@ >$@.S
	../utils/bin2bin $@.bin > $@.bin.bin
	../utils/bin2hex $@.bin > $@.hex
$(TARGET3): $(OBJS) $(OBJ3)
	$(LD) $(LDFLAGS) $(OBJ3) $(OBJS) $(LIBS) -o $@
	or32-uclinux-objcopy --remove-section=.extbss -O binary $@ $@.bin
	or32-uclinux-objdump -t $@ >$@.symbol
	or32-uclinux-objdump -x $@ >$@.header
	or32-uclinux-objdump -s $@ >$@.contents
	or32-uclinux-objdump -D $@ >$@.S
	../utils/bin2bin $@.bin > $@.bin.bin
	../utils/bin2hex $@.bin > $@.hex
$(TARGET4): $(OBJS) $(OBJ4)
	$(LD) $(LDFLAGS) $(OBJ4) $(OBJS) $(LIBS) -o $@
	or32-uclinux-objcopy --remove-section=.extbss -O binary $@ $@.bin
	or32-uclinux-objdump -t $@ >$@.symbol
	or32-uclinux-objdump -x $@ >$@.header
	or32-uclinux-objdump -s $@ >$@.contents
	or32-uclinux-objdump -D $@ >$@.S
	../utils/bin2bin $@.bin > $@.bin.bin
	../utils/bin2hex $@.bin > $@.hex
$(OBJ1): reset.S
	$(CC) $(CFLAGS) $(INCLUDES) -DIC=0 -DDC=0 -DIC_SIZE=$(IC_SIZE) -DDC_SIZE=$(DC_SIZE) $? -o $@
$(OBJ2): reset.S
	$(CC) $(CFLAGS) $(INCLUDES) -DIC=1 -DDC=0 -DIC_SIZE=$(IC_SIZE) -DDC_SIZE=$(DC_SIZE) $? -o $@
$(OBJ3): reset.S
	$(CC) $(CFLAGS) $(INCLUDES) -DIC=0 -DDC=1 -DIC_SIZE=$(IC_SIZE) -DDC_SIZE=$(DC_SIZE) $? -o $@
$(OBJ4): reset.S
	$(CC) $(CFLAGS) $(INCLUDES) -DIC=1 -DDC=1 -DIC_SIZE=$(IC_SIZE) -DDC_SIZE=$(DC_SIZE) $? -o $@
.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) $<
clean:
	rm -f *.o *.or32 *.log *.bin *.srec *.hex *.log stdout.txt *.stackdump *.*.or32 *.*.or32.*

