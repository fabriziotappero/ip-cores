avr-gcc -S tmp.cpp
avr-gcc tmp.cpp
avr-objcopy.exe -j .text -O ihex a.out a.hex
convert_hex2dec.exe 
