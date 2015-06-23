echo Compiling sources...
cavr sieve.c
avrasm32.exe -fI sieve.asm -o test.hex -l test.lst
hexbin test.hex test.bin I

echo Copying binary file to VHDL test directory...
del ..\..\tools\build_vhdl_test\test.bin
copy test.bin ..\..\tools\build_vhdl_test
