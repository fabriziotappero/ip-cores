include ../common/Makefile

OBJ = flash.o stdlib.o stdio.o ui.o main.o

standalone : boot.o $(OBJ)
	$(LD) boot.o $(OBJ) -o void.axf
	$(OPC) void.axf void.bin
	$(MEM) void.bin $(BIN_DIR)

void.bin : start.o $(OBJ)
	$(LD2) start.o $(OBJ) -o void.axf
	$(OPC) void.axf void.bin

upload : void.bin
	$(LOAD) void.bin

details : void.axf $(OBJ)   
	-@$(DMP) void.axf > void.lst
	-@$(DMP) ui.o > ui.lst
	-@$(DMP) stdlib.o > stdlib.lst
	-@$(DMP) stdio.o > stdio.lst
	-@$(DMP) main.o > main.lst
	-@$(DMP) flash.o > flash.lst