Files provided in this directory are intended for
PCI development purposes. Kernel interface provides
some basic functionality for accessing PCI memory mapped
resources on single device. Modules have been tested
on Linux kernels 2.2 and 2.4, inserted with modutils version 2.4.6-1 for i386
IO resources as well as interrupts or DMA (mastership)
are not supported by this interface yet - they will probably be when 
PCI bridge development is finished.
sdram_test.c source and binary is a little program that tests driver response
with Insight's Spartan-II PCI development kit with SDRAM reference design 
loaded. 

I have compiled modules with 
gcc -D__KERNEL__ -DMODULE -c -O and it worked fine - if it doesn't for you, don't ask me why, because I'm not Linux guru

I have inserted modules with 
insmod -f spartan_drv-2.*.o and it also worked, nonetheless insmod was complaining about versions

Have fun,
    Miha Dolenc