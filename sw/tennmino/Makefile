include ../common/Makefile

# Redefine the assembler, with interrupts enabled.
# Found no better solution yet.
AS = $(TOOL_DIR)as.exe --defsym _INTERRUPT=1

OBJ = stdlib.o stdio.o view.o tiles.o interrupt.o main.o

ten.bin : start.o $(OBJ)
	$(LD2) start.o $(OBJ) -o ten.axf
	$(OPC) ten.axf ten.bin

upload : ten.bin
	$(LOAD) ten.bin
   
details : ten.axf $(OBJ)
	-@$(DMP) ten.axf > ten.lst
	-@$(DMP) stdlib.o > stdlib.lst
	-@$(DMP) stdio.o > stdio.lst
	-@$(DMP) tiles.o > tiles.lst
	-@$(DMP) main.o > main.lst