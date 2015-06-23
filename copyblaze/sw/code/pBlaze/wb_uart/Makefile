# path to tools
#DRIVE=E:
DRIVE=/cygdrive/e
TOPPATH=../../../..
TOOLPATH=$(TOPPATH)/sw/tools/asm

AS=$(TOOLPATH)/pBlazASM/pBlazASM/pBlazASM.exe
#MG=$(TOOLPATH)/pBlazASM/pBlazMRG/pBlazMRG.exe
MG=$(TOOLPATH)/pBlazASM/cpBlazeMRG/cpBlazeMRG.exe

DIROUT=$(TOPPATH)/rtl/vhdl/ip/rom

RM = rm -f -v
CP = cp

# List of PSM Files
#ASM_SRC = Test_Mnemonics.asm
ASM_SRC = *.asm
#AFLAGS = -l -m
AFLAGS = -l -x
MGFLAGS =
TEMPLATE = ../template2
ENTITY = cp_ROM_Code

.SUFFIXES : .psm .mem .vhd .psh

# assemble and merge
all:  clean  $(ENTITY).vhd 

# assemble #
$(ENTITY).mem:  $(ASM_SRC)
	$(AS) $(ASM_SRC) $(AFLAGS)
#	$(CP) *.mem $(ENTITY).mem
	$(CP) *.hex $(ENTITY).hex

# merge #
#$(ENTITY).vhd:  $(ENTITY).mem $(TEMPLATE).vhd
$(ENTITY).vhd:  $(ENTITY).mem
#	$(MG) $(MGFLAGS) -e$(ENTITY) $(ENTITY).mem $(TEMPLATE).vhd $(ENTITY).vhd 
	$(MG) $(MGFLAGS) $(ENTITY).hex
	$(CP) $(ENTITY).vhd $(DIROUT)/$(ENTITY).vhd

# clean outputs
clean:
#	$(RM) $(ENTITY).lst
	$(RM) *.lst
#	$(RM) $(ENTITY).mem
	$(RM) *.mem
#	$(RM) $(ENTITY).vhd
	$(RM) *.hex
	$(RM) *.log
	$(RM) *.vhd
	$(RM) *.bin
