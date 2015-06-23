#include <stdlib.h>
#include <stdio.h>
#include "grcommon.h"

report_start()
{
	if (!get_pid()) printf("\nStarting test ...\n");
}

report_end()
{
	printf("\nTested ended\n");
}

char *dev_to_string(unsigned int dev);
int device = 0;
report_device(int dev)
{
	device = dev;
	printf("%s\n", dev_to_string(dev));
	return(1);
}


char *dev_to_subtest(int dev, int test);
report_subtest(int test)
{
	printf("  %s\n", dev_to_subtest(device, test));
}

fail(int dev)
{
	printf("    test failed at %d\n", dev);
}


char *dev_to_string(unsigned int dev)
{
	switch (dev >> 24) {
	case 1:
	  switch ((dev >> 12) & 0x0fff) {
	  case GAISLER_LEON3:   return("LEON3 V8 Processor"); break;
	  case GAISLER_ETHMAC:  return("GR Ethernet MAC"); break;
	  case GAISLER_PCIFBRG:  return("Fast 32-bit PCI Bridge"); break;
	  case GAISLER_LEON3FT: return("LEON3FT V8 Processor"); break;
	  case GAISLER_GPTIMER: return("Modular Timer unit"); break;
	  case GAISLER_IRQMP: return("Interrupt Controller"); break;
	  case GAISLER_APBUART: return("UART"); break;
	  case GAISLER_CANAHB: return("OC CAN AHB interface"); break;
	  case GAISLER_GRGPIO: return("General Purpose I/O port"); break;
	  case GAISLER_FTMCTRL: return("PROM/SRAM/SDRAM Memory controller with EDAC"); break;
	  case GAISLER_FTAHBRAM: return("Generic FT AHB SRAM module"); break;
	  case GAISLER_FTSRCTRL: return("Simple FT SRAM Controller"); break;
	  case GAISLER_SPW: return("SpaceWire Serial Link"); break;
	  case GAISLER_SPICTRL: return("SPI controller"); break;
	  case GAISLER_I2CMST: return("I2C master"); break;
	  default:  return("Unknown device");
	  }
	  break;
	case 4:
	  switch ((dev >> 12) & 0x0fff) {
	  case ESA_LEON2: return("Leon2 SPARC V8 Processor"); break;
	  case ESA_MCTRL: return("Leon2 Memory Controller"); break;
	  case ESA_L2IRQ: return("Leon2 Interrupt Controller"); break;
	  default:  return("Unknown device");
	  }
	  break;
	default:  return("Unknown vendor");
	}
}

char *dev_to_subtest(int dev, int test)
{
    switch (dev >> 24) {
    case VENDOR_GAISLER:
      switch ((dev >> 12) & 0x0fff) {
      case GAISLER_LEON3:
      case GAISLER_LEON3FT:
      case ESA_LEON2:
	switch (test) {
	case 3:   return("register file");
	case 4:   return("multiplier");
	case 5:   return("radix-2 divider");
	case 6:   return("cache system");
	case 7:   return("multi-processing");
	case 8:   return("floating-point unit");
	case 9:   return("itag cache ram");
	case 10:   return("dtag cache ram");
	case 11:   return("idata cache ram");
	case 12:   return("ddata cache ram");
	case 13:   return("GRFPU test");
	case 14:   return("memory management unit");
	default:  return("sub-test");
	}
      case GAISLER_GPTIMER:
	switch (test) {
	case 0:   return("timer 0");
	case 1:   return("timer 1");
	case 2:   return("timer 2");
	case 3:   return("timer 3");
	case 4:   return("timer 4");
	case 5:   return("timer 5");
	case 6:   return("timer 6");
	case 7:   return("timer 7");
	case 8:   return("chain-mode");
	default:  return("sub-test");
	}
      break;
      default:  return("sub-test");
      }
    }
}
