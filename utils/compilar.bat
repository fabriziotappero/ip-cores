@echo off
if not exist %1.c goto error
mb-gcc -Wl,"-Map=%1.map" -Wl,"-Ttext=0x0" -Wa,-ahlms=%1.lst -nostartfiles -nodefaultlibs %1.c
mb-objcopy -O binary a.out %1.bin
..\utils\bin2bram ..\rtl\openfire_template_bootram.v %1.bin %1.v
rm a.out
rm %1.bin
goto fin
:error
echo No existe fichero %1.c
:fin
