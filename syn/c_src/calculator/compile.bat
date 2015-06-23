path;
path=..\..\..\gccmips_elf
as -o boot.o  ..\plasmaboot.asm
gcc  -O2 -O  -Dmain=main2 -Wall -S  uart_echo_test.c
gcc  -O2 -O  -Dmain=main2 -Wall -c -s uart_echo_test.c
ld.exe -Ttext 0 -eentry -Map test.map -s -N -o test.exe boot.o uart_echo_test.o 
objdump.exe --disassemble test.exe > list.txt
rem copy test.map 
rem copy count_tak.s 
rem copy list.txt 
convert_mips.exe -sp16k
copy code0.hex  ..\..\altera\*.*
copy code1.hex  ..\..\altera\*.*
copy code2.hex  ..\..\altera\*.*
copy code3.hex  ..\..\altera\*.*
copy code0.coe  ..\..\xilinx\*.*
copy code1.coe  ..\..\xilinx\*.*
copy code2.coe  ..\..\xilinx\*.*
copy code3.coe  ..\..\xilinx\*.*
rem copy code.txt  
copy ram1k0.mif ..\..\xilinx\*.*
copy ram1k1.mif ..\..\xilinx\*.*
copy ram1k2.mif ..\..\xilinx\*.*
copy ram1k3.mif ..\..\xilinx\*.*
