
#include <linux/kernel.h>
#define __NO_VERSION__
#include <linux/module.h>
#include <linux/types.h>
#include <linux/ioport.h>
#include <linux/pci.h>
#include <linux/pagemap.h>
#include <linux/interrupt.h>
#include <linux/proc_fs.h>
#include <asm/io.h>

#include "pexmodule.h"
#include "pexproc.h"
#include "ambpexregs.h"
#include "hardware.h"

//--------------------------------------------------------------------

void pex_register_proc( char *name, void *fptr, void *data )
{
    create_proc_read_entry( name, 0, NULL, fptr, data );
}

//--------------------------------------------------------------------

void pex_remove_proc( char *name )
{
    remove_proc_entry( name, NULL );
}

//--------------------------------------------------------------------

int pex_show_capabilities( char *buf, struct pex_device *brd )
{
    int i = 0;
    int res = 0;
    char *p = buf;
    u8 cap = 0;
    u32 cap_id = 0;

    struct pci_dev *m_pci = brd->m_pci;
    if(!m_pci) {
        goto err_exit;
    }

    if(!buf) {
        goto err_exit;
    }

    p += sprintf(p,"\n" );

    res = pci_read_config_byte(m_pci, 0x34, &cap);
    if(res < 0) {
        p += sprintf(p, "  Error read capabilities pointer\n");
        goto err_exit;
    }

    p += sprintf(p, "  Capability pointer: 0x%x\n", cap);

    while(1) {

        res = pci_read_config_dword(m_pci, cap, &cap_id);
        if(res < 0) {
            p += sprintf(p, "  Error read capabilities id\n");
            goto err_exit;
        }

        p += sprintf(p, "  Capability ID: 0x%x\n", cap_id);

        if((cap_id & 0xff) == 0x10) {
            break;
        }

        cap = ((cap_id >> 8) & 0xff);
        if(!cap)
            break;
    }

    if((cap_id & 0xff) != 0x10) {
        p += sprintf(p, "  Can't find PCI Express capabilities\n");
        goto err_exit;
    }

    p += sprintf(p,"\n" );
    p += sprintf(p, "  PCI Express Capability Register Set\n");
    p += sprintf(p,"\n" );

    for(i=0; i<9; i++) {
        u32 reg = 0;
        int j = cap + 4*i;
        res = pci_read_config_dword(m_pci, j, &reg);
        if(res < 0) {
            p += sprintf(p, "  Error read capabilities sructure: offset %x\n", j);
            goto err_exit;
        }
        p += sprintf(p, "  0x%x:  0x%X\n", j, reg);
    }

err_exit:

    return (p-buf);
}

int pex_proc_info(  char *buf, 
		    char **start, 
		    off_t off,
		    int count, 
		    int *eof, 
		    void *data )
{
    int iBlock = 0;
    char *p = buf;
    struct pex_device *brd = (struct pex_device*)data;

    if(!brd) {
        p += sprintf(p,"  Invalid device pointer\n" );
        *eof = 1;
        return p - buf;
    }

    p += pex_show_capabilities(p, brd);

    p += sprintf(p,"\n" );
    p += sprintf(p,"  Device information\n" );

    p += sprintf(p, "  m_TotalIRQ = %d\n", atomic_read(&brd->m_TotalIRQ));



    for(iBlock = 0; iBlock < brd->m_BlockCnt; iBlock++)
    {
        u32 FifoAddr = 0;
        u16 val = 0;

        FifoAddr = (iBlock + 1) * PE_FIFO_ADDR;
        val = ReadOperationWordReg(brd, PEFIFOadr_BLOCK_ID + FifoAddr);

        if((val & 0x0FFF) != PE_EXT_FIFO_ID)
            continue;

        p += sprintf(p,"\n" );
        p += sprintf(p,"  PE_EXT_FIFO %d\n", iBlock+1 );
        p += sprintf(p,"\n" );

        p += sprintf(p,"  BLOCK_ID = %x\n", (val & 0x0FFF) );
        val = ReadOperationWordReg(brd, PEFIFOadr_BLOCK_VER + FifoAddr);
        p += sprintf(p,"  BLOCK_VER = %x\n", (val & 0xFFFF) );
        val = ReadOperationWordReg(brd, PEFIFOadr_FIFO_ID + FifoAddr);
        p += sprintf(p,"  FIFO_ID = %x\n", (val & 0xFFFF) );
        val = ReadOperationWordReg(brd, PEFIFOadr_FIFO_NUM + FifoAddr);
        p += sprintf(p,"  FIFO_NUMBER = %x\n", (val & 0xFFFF) );
        val = ReadOperationWordReg(brd, PEFIFOadr_DMA_SIZE + FifoAddr);
        p += sprintf(p,"  RESOURCE = %x\n", (val & 0xFFFF) );
        val = ReadOperationWordReg(brd, PEFIFOadr_FIFO_CTRL + FifoAddr);
        p += sprintf(p,"  DMA_MODE = %x\n", (val & 0xFFFF) );
        val = ReadOperationWordReg(brd, PEFIFOadr_DMA_CTRL + FifoAddr);
        p += sprintf(p,"  DMA_CTRL = %x\n", (val & 0xFFFF) );
        val = ReadOperationWordReg(brd, PEFIFOadr_FIFO_STATUS + FifoAddr);
        p += sprintf(p,"  FIFO_STATUS = %x\n", (val & 0xFFFF) );
        val = ReadOperationWordReg(brd, PEFIFOadr_FLAG_CLR + FifoAddr);
        p += sprintf(p,"  FLAG_CLR = %x\n", (val & 0xFFFF) );
        val = ReadOperationWordReg(brd, PEFIFOadr_PCI_ADDRL + FifoAddr);
        p += sprintf(p,"  PCI_ADRL = %x\n", (val & 0xFFFF) );
        val = ReadOperationWordReg(brd, PEFIFOadr_PCI_ADDRH + FifoAddr);
        p += sprintf(p,"  PCI_ADRH = %x\n", (val & 0xFFFF) );
        val = ReadOperationWordReg(brd, PEFIFOadr_LOCAL_ADR + FifoAddr);
        p += sprintf(p,"  LOCAL_ADR = %x\n", (val & 0xFFFF) );
    }

    *eof = 1;

    return p - buf;
}

//--------------------------------------------------------------------
