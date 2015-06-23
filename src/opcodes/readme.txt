This is a basic opcode test bench which tries all supported opcodes. See the
source comments. This code has been lifted whole from the Plasma project and
then gradually modified to its present state.

This program can be simulated (both Modelsim and SW simulator) but it can't be 
synthesized to a hardware demo (see makefiles). Only a 'sim' target is provided
in the makefile.

WARNING: the gnu assembler expands DIV* instructions, inserting code that 
handles division by zero. Bear that in mind when reading the listing file.
