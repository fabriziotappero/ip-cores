all: hex2mif
	mipsel-unknown-linux-gnu-gcc -mips1 -o system_onchip_memory.hex -nostdlib -T linker.x -mno-abicalls -Wl,--oformat=ihex header.S bootloader.c
	./hex2mif < system_onchip_memory.hex > system_onchip_memory.mif
	mif2hex system_onchip_memory.mif ./../system_onchip_memory.hex

hex2mif: hex2mif.cpp
	g++ -o hex2mif -O2 hex2mif.cpp
