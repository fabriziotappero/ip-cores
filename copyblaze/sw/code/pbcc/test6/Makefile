# tools paths
DRIVE=/cygdrive/c

PATH_TOP=../../../..
PATH_TOOL=$(PATH_TOP)/sw/tools
PATH_ASM=asm
PATH_COMP=comp/pbcc/sdcc

CC=$(PATH_TOOL)/$(PATH_COMP)/bin/sdcc.exe
AS=$(PATH_TOOL)/$(PATH_ASM)/pBlazASM/pBlazASM/pBlazASM.exe
MG=$(PATH_TOOL)/$(PATH_ASM)/pBlazASM/cpBlazeMRG/cpBlazeMRG.exe

# output directory
DIROUT=$(PATH_TOP)/rtl/vhdl/ip/rom

# remove command
RM = rm -f -v
CP = cp

# Compiler Flags
C_SRC = test6.c
CFLAGS = -mpblaze -S
IFLAGS = -I"$(PATH_TOOL)/$(PATH_COMP)/device/include/pblaze"

# Assembler Flags
ASM_SRC = *.psm
AFLAGS = -k -l -x

# Merge Flags
MGFLAGS =
ENTITY = cp_ROM_Code

.SUFFIXES : .psm .mem .vhd .psh

# ALL
all:  clean  $(ENTITY).vhd 

# compile #
$(ENTITY).psm:  $(C_SRC)
	$(CC) $(C_SRC) $(CFLAGS) $(IFLAGS)

# assemble #
$(ENTITY).mem:  $(ENTITY).psm
	$(AS) $(ASM_SRC) $(AFLAGS)
	$(CP) *.hex $(ENTITY).hex

# merge #
$(ENTITY).vhd:  $(ENTITY).mem
	$(MG) $(MGFLAGS) $(ENTITY).hex
	$(CP) $(ENTITY).vhd $(DIROUT)/$(ENTITY).vhd


# clean outputs
clean:
	$(RM) *.lst
	$(RM) *.mem
	$(RM) *.hex
	$(RM) *.log
	$(RM) *.vhd
	$(RM) *.bin
