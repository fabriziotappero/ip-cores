static unsigned int PCI_ADDR;
static unsigned int PCI_CONF;
static unsigned int PCI_MEM_START;
//#define PCI_MEM_END   0x00000000
//#define PCI_MEM_SIZE  (PCI_MEM_START - PCI_MEM_END)

#include "pcitest.h"

//#define DEBUG 1 

#ifdef DEBUG
#define DBG(x...) printf(x)
#else
#define DBG(x...) 
#endif

/* allow for overriding these definitions */
#ifndef PCI_CONFIG_ADDR
#define PCI_CONFIG_ADDR			0xcf8
#endif
#ifndef PCI_CONFIG_DATA
#define PCI_CONFIG_DATA			0xcfc
#endif
#define PCI_INVALID_VENDORDEVICEID	0xffffffff
#define PCI_MULTI_FUNCTION		0x80

typedef struct {
	volatile unsigned int cfg_stat;
	volatile unsigned int bar0;
	volatile unsigned int page0;
	volatile unsigned int bar1;
	volatile unsigned int page1;
	volatile unsigned int iomap;
	volatile unsigned int stat_cmd;
} LEON3_GRPCI_Regs_Map;

static LEON3_GRPCI_Regs_Map *pcic;

struct pci_res {
    unsigned int size;
    unsigned char bar;
    unsigned char devfn;
};

static inline unsigned int flip_dword (unsigned int l)
{
        return ((l&0xff)<<24) | (((l>>8)&0xff)<<16) | (((l>>16)&0xff)<<8)| ((l>>24)&0xff);
}

int
pci_read_config_dword(unsigned char bus, unsigned char slot, unsigned char function, unsigned char offset, unsigned int *val) {

    volatile unsigned int *pci_conf;

    if (offset & 3) return PCIBIOS_BAD_REGISTER_NUMBER;
        
    if (slot >= 21) {
        *val = 0xffffffff;
        return PCIBIOS_SUCCESSFUL;
    }

    pci_conf = (int*)(PCI_CONF + ((slot<<11) | (function<<8) | offset));

    *val =  *pci_conf;

    if (pcic->cfg_stat & 0x100) {
        *val = 0xffffffff;
    }

/*    DBG("pci_read - bus: %d, dev: %d, fn: %d, off: %d => addr: %x, val: %x\n", bus, slot, function, offset,  (1<<(11+slot) ) | ((function & 7)<<8) |  (offset&0x3f), *val); 
 */

    return PCIBIOS_SUCCESSFUL;
}


int 
pci_read_config_word(unsigned char bus, unsigned char slot, unsigned char function, unsigned char offset, unsigned short *val) {
    unsigned int v;

    if (offset & 1) return PCIBIOS_BAD_REGISTER_NUMBER;

    pci_read_config_dword(bus, slot, function, offset&~3, &v);
    *val = 0xffff & (v >> (8*(offset & 3)));

    return PCIBIOS_SUCCESSFUL;
}


int 
pci_read_config_byte(unsigned char bus, unsigned char slot, unsigned char function, unsigned char offset, unsigned char *val) {
    unsigned int v;

    pci_read_config_dword(bus, slot, function, offset&~3, &v);

    *val = 0xff & (v >> (8*(offset & 3)));

    return PCIBIOS_SUCCESSFUL;
}


int
pci_write_config_dword(unsigned char bus, unsigned char slot, unsigned char function, unsigned char offset, unsigned int val) {

    volatile unsigned int *pci_conf;

    if (offset & 3 || bus != 0) return PCIBIOS_BAD_REGISTER_NUMBER;


    pci_conf = (int*)(PCI_CONF + ((slot<<11) | (function<<8) | (offset & ~3)));

    *pci_conf = val;

/*    DBG("pci write - bus: %d, dev: %d, fn: %d, off: %d => addr: %x, val: %x\n", bus, slot, function, offset, (1<<(11+slot) ) | ((function & 7)<<8) |  (offset&0x3f), val); */

    return PCIBIOS_SUCCESSFUL;
}


int 
pci_write_config_word(unsigned char bus, unsigned char slot, unsigned char function, unsigned char offset, unsigned short val) {
    unsigned int v;

    if (offset & 1) return PCIBIOS_BAD_REGISTER_NUMBER;

    pci_read_config_dword(bus, slot, function, offset&~3, &v);

    v = (v & ~(0xffff << (8*(offset&3)))) | ((0xffff&val) << (8*(offset&3)));

    return pci_write_config_dword(bus, slot, function, offset&~3, v);
}


int 
pci_write_config_byte(unsigned char bus, unsigned char slot, unsigned char function, unsigned char offset, unsigned char val) {
    unsigned int v;

    pci_read_config_dword(bus, slot, function, offset&~3, &v);

    v = (v & ~(0xff << (8*(offset&3)))) | ((0xff&val) << (8*(offset&3)));
    
    return pci_write_config_dword(bus, slot, function, offset&~3, v);
}


void init_grpci(void) {

    volatile unsigned int *page0 =  (unsigned volatile int *)PCI_MEM_START;
    unsigned int data, addr;

    pci_write_config_dword(0,0,0,0x10, 0xffffffff);
    pci_read_config_dword(0,0,0,0x10, &addr);
    pci_write_config_dword(0,0,0,0x10, flip_dword(0x80000000));    /* Setup bar0 to nonzero value (grpci considers BAR==0 as invalid) */
    addr = (~flip_dword(addr)+1)>>1;                               /* page0 is accessed through upper half of bar0 */
    pcic->cfg_stat |= 0x80000000;                                  /* Setup mmap reg so we can reach bar0 */ 
    page0[addr/4] = flip_dword(0x80000000);                                             /* Disable bytetwisting ... */

     
    /* set 1:1 mapping between AHB -> PCI memory */
    pcic->cfg_stat = (pcic->cfg_stat & 0x0fffffff) | PCI_MEM_START;
    
    /* and map system RAM at pci address 0xc0000000 */ 
    pci_write_config_dword(0, 0, 0, 0x14, 0xc0000000);
    pcic->page1 = 0x40000000;
    
    /* set as bus master and enable pci memory responses */  
    pci_read_config_dword(0, 0, 0, 0x4, &data);
    pci_write_config_dword(0, 0, 0, 0x4, data | 0x6);
    

}

void pci_mem_enable(unsigned char bus, unsigned char slot, unsigned char function) {
    unsigned int data;

    pci_read_config_dword(0, slot, function, PCI_COMMAND, &data);
    pci_write_config_dword(0, slot, function, PCI_COMMAND, data | PCI_COMMAND_MEMORY);  

}

void pci_master_enable(unsigned char bus, unsigned char slot, unsigned char function) {
    unsigned int data;

    pci_read_config_dword(0, slot, function, PCI_COMMAND, &data);
    pci_write_config_dword(0, slot, function, PCI_COMMAND, data | PCI_COMMAND_MASTER);  

}

static inline void swap_res(struct pci_res **p1, struct pci_res **p2) {

    struct pci_res *tmp = *p1;
    *p1 = *p2;
    *p2 = tmp;

}

/* pci_allocate_resources
 *
 * This function scans the bus and assigns PCI addresses to all devices. It handles both
 * single function and multi function devices. All allocated devices are enabled and
 * latency timers are set to 40.
 *
 * NOTE that it only allocates PCI memory space devices. IO spaces are not enabled.
 * Also, it does not handle pci-pci bridges. They are left disabled. 
 *
 *
*/
void pci_allocate_resources(void) {

    unsigned int slot, numfuncs, func, id, pos, size, tmp, i, swapped, addr, dev, fn;
    unsigned char header;
    struct pci_res **res;
    int bar;

 /*    res = (struct pci_res **) malloc(sizeof(struct pci_res *)*32*8*6); */

/*     for (i = 0; i < 32*8*6; i++) { */
/*         res[i] = (struct pci_res *) malloc(sizeof(struct pci_res));      */
/*         res[i]->size = 0; */
/*         res[i]->devfn = i; */
/*     } */

    addr = PCI_MEM_START+0x10000000;
    for(slot = 1; slot < PCI_MAX_DEVICES; slot++) {

        pci_read_config_dword(0, slot, 0, PCI_VENDOR_ID, &id);

        if(id == PCI_INVALID_VENDORDEVICEID || id == 0) {
            /*
             * This slot is empty
             */
            continue;
        }

        pci_read_config_byte(0, slot, 0, PCI_HEADER_TYPE, &header);
      
        if(header & PCI_MULTI_FUNCTION)	{
            numfuncs = PCI_MAX_FUNCTIONS;
        }
        else {
            numfuncs = 1;
        }

        for(func = 0; func < numfuncs; func++) {

            pci_read_config_dword(0, slot, func, PCI_VENDOR_ID, &id);
            if(id == PCI_INVALID_VENDORDEVICEID || id == 0) {
                continue;
            }

            pci_read_config_dword(0, slot, func, PCI_CLASS_REVISION, &tmp);
            tmp >>= 16;
            if (tmp == PCI_CLASS_BRIDGE_PCI) {
                continue;
            }
            
            for (pos = 0; pos < 6; pos++) {
                pci_write_config_dword(0, slot, func, PCI_BASE_ADDRESS_0 + (pos<<2), 0xffffffff);
                pci_read_config_dword(0, slot, func, PCI_BASE_ADDRESS_0 + (pos<<2), &size);

                if (size == 0 || size == 0xffffffff || (size & 0xff1) != 0)
                    continue;

                else {
                    size &= 0xfffffff0;
           /*          res[slot*8*6+func*6+pos]->size  = ~size+1; */
/*                     res[slot*8*6+func*6+pos]->devfn = slot*8 + func; */
/*                     res[slot*8*6+func*6+pos]->bar   = pos; */

		    size  = ~size+1;
                    bar = pos;
         	    dev = (slot*8 + func) >> 3;
         	    fn  = (slot*8 + func) & 7;

		    pci_write_config_dword(0, dev, fn, PCI_BASE_ADDRESS_0+bar*4, addr);
		    addr += size; 
		    pci_read_config_dword(0, dev, fn, 0xC, &tmp);
		    pci_write_config_dword(0, dev, fn, 0xC, tmp|0x4000);

		    pci_mem_enable(0, dev, fn);

                    DBG("Slot: %d, function: %d, bar%d size: %x\n", slot, func, pos, ~size+1);
                }
            }
        }
    }


    /* Sort the resources in descending order */ 

 /*    swapped = 1; */
/*     while (swapped == 1) { */
/*         swapped = 0; */
/*         for (i = 0; i < 32*8*6-1; i++) { */
/*             if (res[i]->size < res[i+1]->size) { */
/*                 swap_res(&res[i], &res[i+1]); */
/*                 swapped = 1; */
/*             } */
/*         } */
/*         i++; */
/*     } */

    /* Assign the BARs */

  /*   addr = PCI_MEM_START; */
/*     for (i = 0; i < 32*8*6; i++) { */

/*         if (res[i]->size == 0) { */
/*             goto done; */
/*         } */
/*         if ( (addr + res[i]->size) > PCI_MEM_END) { */
/*             goto done; */
/*         } */
    
/*         dev = res[i]->devfn >> 3; */
/*         fn  = res[i]->devfn & 7; */
    
/*         DBG("Assigning PCI addr %x to device %d, function %d, bar %d\n", addr, dev, fn, res[i]->bar); */
/*         pci_write_config_dword(0, dev, fn, PCI_BASE_ADDRESS_0+res[i]->bar*4, addr); */
/*         addr += res[i]->size; */

/*         /\* Set latency timer to 64 *\/ */
/*         pci_read_config_dword(0, dev, fn, 0xC, &tmp);     */
/*         pci_write_config_dword(0, dev, fn, 0xC, tmp|0x4000); */

/*         pci_mem_enable(0, dev, fn);   */

/*     }  */


    
/* done: */

    
    /*   for (i = 0; i < 1536; i++) { */
/*         free(res[i]); */
/*     } */
/*     free(res); */
}





/*
 * This routine determines the maximum bus number in the system
 */
void init_pci()
{
//    DBG("Initializing PCI\n");
    init_grpci();
    pci_allocate_resources();
//    DBG("PCI resource allocation done\n");

}

static inline int storemem(int addr, int val)
{
  asm volatile (" sta %0, [%1]1 \n "
      : // no outputs
      : "r"(val), "r" (addr)
    );
}

static inline int loadmem(int addr)
{
  int tmp;
  asm volatile (" lda [%1]1, %0 "
      : "=r"(tmp)
      : "r"(addr)
    );
  return tmp;
}


int pci_test(int apbaddr, int ioaddr, int ahbaddr) {

int pcidata ;

    PCI_ADDR  = 0x80000400;
    PCI_CONF  = 0xfff10000;
    PCI_MEM_START  = 0xc0000000;
    pcic = (LEON3_GRPCI_Regs_Map *) PCI_ADDR;
    report_device(0x01014000);

    init_pci();
   
    storemem(0xc0080000, 0xdeadbeef);
    pcidata = loadmem(0xc0080000);

    return 0;

}
