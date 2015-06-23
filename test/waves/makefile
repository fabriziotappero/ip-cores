# Simple Makefile Volker Oth (c) 1999
# edited by AVRfreaks.net nov.2001

########### change these lines according to your project ##################

#put the name of the target mcu here (at90s8515, at90s8535, attiny22, atmega603 etc.)
#    MCU = at90s8515
    MCU = atmega103

#put the name of the target file here (without extension)
   TRG   = waves

#put your C sourcefiles here
   SRC   = $(TRG).c

#put additional assembler source file here
   ASRC    =

#additional libraries and object files to link
   LIB   =

#additional includes to compile
   INC   =

#assembler flags
   ASFLAGS = -mdwarf2-asm -Wa, -gstabs

#compiler flags
   CPFLAGS  = -g  -Os -Wall -Wstrict-prototypes -Wa,-ahlms=$(<:.c=.lst) -lm

#linker flags
   LDFLAGS = -Wl,-Map=$(TRG).map,--cref -lm


########### you should not need to change the following line #############
#include $(AVR)/avrfreaks/avr_make
include c:\programs\avrgcc\avrfreaks\avr_make

###### dependencies, add any dependencies you need here ###################
$(TRG).o : $(TRG).c
