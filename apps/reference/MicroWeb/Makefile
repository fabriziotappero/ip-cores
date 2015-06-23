#
#
#

SHELL = /bin/sh
SDCCFLAGS = --model-large -I /home/dinesha/download/sdcc/device/include/mcs51 -I /home/dinesha/download/sdcc/device/include/  -L /home/dinesha/download/sdcc/device/lib/build/large
ASLINKFLAGS = --code-loc 0x8000 --data-loc 0x30 --stack-loc 0x20 --xram-loc 0xD000
MODULES = main.rel csio.rel csioa.rel tcp.rel udp.rel icmp.rel arp.rel ip.rel

%.rel: %.c
	sdcc $(SDCCFLAGS) -c $<

#main.rel: main.c
#	sdcc $(SDCCFLAGS) -c $<

%.rel: %.asm
	sdas8051 -los $<

all: microweb.hex

microweb.hex :: $(MODULES)
	sdcc $(SDCCFLAGS) $(ASLINKFLAGS) $(MODULES)
	packihx main.ihx > microweb.hex

clean:
	rm -f tcp.asm udp.asm icmp.asm arp.asm ip.asm csio.asm main.asm main.mem
	rm -f *.hex *.ihx *.lnk *.lst *.map *.rel *.rst *.sym

