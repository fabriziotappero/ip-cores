path;
path=..\..\..\gccmips_elf
as -o boot.o  ..\plasmaboot.asm
gcc  -O2 -O  -DRTL_SIM -Dmain=main2 -Wall -S  count_tak.c
gcc  -O2 -O  -DRTL_SIM -Dmain=main2 -Wall -c -s count_tak.c
ld.exe -Ttext 0 -eentry -Map test.map -s -N -o test.exe boot.o count_tak.o 
objdump.exe --disassemble test.exe > list.txt
rem copy test.map 
rem copy count_tak.s 
rem copy list.txt 
convert_mips.exe -sp16k
copy code0.hex ..\..\..\rtl\altera\*.*
copy code1.hex ..\..\..\rtl\altera\*.*
copy code2.hex ..\..\..\rtl\altera\*.*
copy code3.hex ..\..\..\rtl\altera\*.*
copy code0.coe ..\..\..\rtl\xilinx\*.*
copy code1.coe ..\..\..\rtl\xilinx\*.*
copy code2.coe ..\..\..\rtl\xilinx\*.*
copy code3.coe ..\..\..\rtl\xilinx\*.*
rem copy code.txt  
copy ram1k0.mif ..\..\..\rtl\xilinx\*.*
copy ram1k1.mif ..\..\..\rtl\xilinx\*.*
copy ram1k2.mif ..\..\..\rtl\xilinx\*.*
copy ram1k3.mif ..\..\..\rtl\xilinx\*.*
