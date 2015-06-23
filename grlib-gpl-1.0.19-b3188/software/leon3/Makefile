VPATH=$(GRLIB)/software/leon3
XCC=sparc-elf-gcc -I$(GRLIB)/software/leon3 $(BOPT)
XAS=sparc-elf-gcc -c -I. -I$(GRLIB)/software/leon3 $(BOPT)
XAR=sparc-elf-ar
XCFLAGS=-O2 -g -msoft-float
XLDFLAGS=-L./ lib3tests.a

PROGS = report_device apbuart divtest multest regtest \
	cache gpio ramfill ramtest irqmp leon3_test gptimer \
	mulasm cacheasm spwtest mptest fpu spwtest mptest grfpu_ops \
	base_test can_oc mmu mmu_asm pcitest greth grfpu_test atactrl \
	grcan i2cmst spictrl greth_api misc spimctrl


OFILES = $(PROGS:%=%.o)

%.o: %.c
	$(XCC) $(XCFLAGS) -c  $<

%.o: %.S
	$(XCC) $(XCFLAGS) -c  $<

fpu.o: fpu.c
	$(XCC) -ffast-math -O3 -c  $<

multest.o: multest.c
	$(XCC) -O2 -c -mv8  $<

divtest.o: divtest.c
	$(XCC) -O2 -c -mv8  $<

greth_api.o : $(GRLIB)/software/greth/greth_api.c
	$(XCC) -g -msoft-float -c $(GRLIB)/software/greth/greth_api.c

lib3tests.a: $(OFILES)
	$(XAR) -cr lib3tests.a $(OFILES)


soft: prom.srec sram.srec sdram.srec $(EXTRA_SOFT)

prom.o: prom.S prom.h
	$(XAS) $<
prom.exe: prom.o
	$(XCC) -nostdlib -Tlinkprom -N -L./ -Ttext=0 -nostartfiles -o prom.exe $<

prom.srec: prom.exe
	sparc-elf-objcopy -O srec prom.exe prom.srec

systest.exe: systest.c lib3tests.a
	$(XCC) $(XCFLAGS) systest.c $(XLDFLAGS) -o systest.exe

sdram.srec: systest.exe
	sparc-elf-objcopy -O srec systest.exe sdram.srec

sram.srec: systest.exe
	sparc-elf-objcopy -O srec systest.exe sram.srec

soft-clean:
	-rm -rf *.o *.exe *.a

mmusoft:
	make -f Makefile.img mmusoft

standalone.exe: systest.c standalone.c lib3tests.a
	$(XCC) $(XCFLAGS) systest.c $(VPATH)/standalone.c $(XLDFLAGS) -o standalone.exe
