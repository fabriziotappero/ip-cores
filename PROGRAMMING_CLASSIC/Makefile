# **********************************************
# Programs to build
# **********************************************

PROGS = My_Program

# **********************************************
# Endianness EB | EL
# **********************************************

#ENDIAN  = EB
ENDIAN  = EL

# **********************************************
# Bootstrap object file
# **********************************************

BOOTSTRAP = crt0.o

# **********************************************
# Compiler toolchain
# **********************************************

ifeq ($(ENDIAN),EL)
CC        = mipsel-linux-gcc
LD        = mipsel-linux-ld
OBJCOPY   = mipsel-linux-objcopy
OBJDUMP   = mipsel-linux-objdump
endif

ifeq ($(ENDIAN),EB)
CC        = mips-linux-gcc
LD        = mips-linux-ld
OBJCOPY   = mips-linux-objcopy
OBJDUMP   = mips-linux-objdump
endif

# **********************************************
# Compiler and linker options
# **********************************************

W_OPTS    = -Wimplicit -Wformat -Wall -Wstrict-prototypes
W_OPTS_A  = -Wformat -Wall -Wstrict-prototypes


CC_OPTS   = -Wa,-32 -mips1 -mno-abicalls -fno-pic -G 0 -pipe \
	    -D$(ENDIAN) -fno-strict-aliasing -c -nostdinc

CC_OPTS_A = -Wa,-32 -mips1 -mno-abicalls -fno-pic -G 0 -pipe \
	    -D$(ENDIAN) -fno-strict-aliasing -c -nostdinc


LD_SCRIPT = link.xn
LD_OPTS   = -G 0 -static -T $(LD_SCRIPT)

ifeq ($(ENDIAN),EB)
LD_FORMAT = elf32-tradbigmips
endif

ifeq ($(ENDIAN),EL)
LD_FORMAT = elf32-tradlittlemips
endif


# **********************************************
# Rules
# **********************************************

%.o : %.c
	$(CC) $(W_OPTS) $(CC_OPTS) -o $@ $<

%.o : %.S
	$(CC) $(W_OPTS_A) $(CC_OPTS_A) -o $@ $<

%.o : %.s
	$(CC) $(W_OPTS_A) $(CC_OPTS_A) -o $@ $<

all: $(PROGS)

	
My_Program : $(BOOTSTRAP) My_Program.o
	$(LD) $(LD_OPTS) -o $@ $?
	$(OBJCOPY) -O binary $@ $@.bin

clean :
	rm -f $(PROGS) *.bin *.o
	rm -f *~

