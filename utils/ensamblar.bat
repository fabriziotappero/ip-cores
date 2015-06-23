@echo off
if not exist %1.asm goto error
mb-as -a=%1.lst -o %1.o %1.asm %2 %3 %4 %5 %6
mb-ld -N -Ttext 0x0 --cref -Map %1.map -o %1.elf %1.o
mb-objcopy -O binary %1.elf %1.bin
..\..\utils\bin2bram ..\..\rtl\openfire_template_bootram.v %1.bin %1.v
rm %1.o
rm %1.elf
goto fin
:error
echo error: %1.asm no existe
:fin
