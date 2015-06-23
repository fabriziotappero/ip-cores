#
#
#

SHELL = /bin/sh
SDCCFLAGS = --model-large -I /cygdrive/c/Program\ Files/SDCC/include/mcs51 -I /cygdrive/c/Program\ Files/SDCC/include/  -L /cygdrive/c/Program\ Files/SDCC/lib/large --debug 
ASLINKFLAGS = --code-loc 0x040 --data-loc 0x0000 --stack-loc 0x040 --xram-loc 0x0000
MODULES = main.rel menu.rel ip.rel lcd.rel tcp.rel udp.rel icmp.rel http.rel ethernet.rel arp.rel enc28j60.rel

%.rel: %.c
	sdcc $(SDCCFLAGS) -c $<

#main.rel: main.c
#	sdcc $(SDCCFLAGS) -c $<

all: webserver.hex

webserver.hex : $(MODULES)
	sdcc $(SDCCFLAGS) $(ASLINKFLAGS) $(MODULES)
	packihx main.ihx > webserver.hex

clean:
	rm -f *.asm *.hex *.ihx *.lnk *.lst *.map *.rel *.rst *.sym *.mem

