/*****************************************************************************/
/*   This file is a part of the GRLIB VHDL IP LIBRARY                        */
/*   Copyright (C) 2007 GAISLER RESEARCH                                     */
/*                                                                           */
/*   This program is free software; you can redistribute it and/or modify    */
/*   it under the terms of the GNU General Public License as published by    */
/*   the Free Software Foundation; either version 2 of the License, or       */
/*   (at your option) any later version.                                     */
/*                                                                           */
/*   See the file COPYING for the full details of the license.               */
/*****************************************************************************/

/* Changelog */
/* 2008-02-01: GRETH API separated from test  - Marko Isomaki */

#include "greth_api.h"

/* Bypass cache load  */
static inline int load(int addr)
{
    int tmp;        
    asm(" lda [%1]1, %0 "
        : "=r"(tmp)
        : "r"(addr)
        );
    return tmp;
}

static inline int save(unsigned int addr, unsigned int data)
{
    *((volatile unsigned int *)addr) = data;
}

/* Allocate memory aligned to the size */
static char *almalloc(int sz)
{
    char *tmp;
    tmp = calloc(1,2*sz);
    tmp = (char *) (((int)tmp+sz) & ~(sz -1));
    return(tmp);
}

int read_mii(int phyaddr, int addr, volatile greth_regs *regs)
{
    unsigned int tmp;

    do {
        tmp = load((int)&regs->mdio);
    } while (tmp & GRETH_MII_BUSY);

    tmp = (phyaddr << 11) | ((addr&0x1F) << 6) | 2;
    save((int)&regs->mdio, tmp);
  
    do {
        tmp = load((int)&regs->mdio);
    } while (tmp & GRETH_MII_BUSY);

    if (!(tmp & GRETH_MII_NVALID)) {
        tmp = load((int)&regs->mdio);
        return (tmp>>16)&0xFFFF;
    }
    else {
        /* printf("GRETH: failed to read mii\n"); */
        return -1;
    }
}

void write_mii(int phyaddr, int addr, int data, volatile greth_regs *regs)
{
    unsigned int tmp;

    do {
        tmp = load((int)&regs->mdio);
    } while (tmp & GRETH_MII_BUSY);
    
    tmp = ((data&0xFFFF)<<16) | (phyaddr << 11) | ((addr&0x1F) << 6) | 1;

    save((int)&regs->mdio, tmp);

    do {
        tmp = load((int)&regs->mdio);
    } while (tmp & GRETH_MII_BUSY);

}

int greth_set_mac_address(struct greth_info *greth, unsigned char *addr)
{
    greth->esa[0] = addr[0];
    greth->esa[1] = addr[1];
    greth->esa[2] = addr[2];
    greth->esa[3] = addr[3];
    greth->esa[4] = addr[4];
    greth->esa[5] = addr[5];
    save((int)&greth->regs->esa_msb, addr[0] << 8 | addr[1]);
    save((int)&greth->regs->esa_lsb, addr[2] << 24 | addr[3] << 16 | addr[4] << 8 | addr[5]);
    return 1;
}

int greth_init(struct greth_info *greth) {

    unsigned int tmp;
    int i;
    int duplex, speed;
    int gbit;
 
    tmp = load((int)&greth->regs->control);
    greth->gbit = (tmp >> 27) & 1;
    greth->edcl = (tmp >> 31) & 1;

    if (greth->edcl == 0) {
            /* Reset the controller. */
            save((int)&greth->regs->control, GRETH_RESET);
            
            do {
                    tmp = load((int)&greth->regs->control);
            } while (tmp & GRETH_RESET);
    }

    /* Get the phy address which assumed to have been set
     * correctly with the reset value in hardware 
     */
    tmp = load((int)&greth->regs->mdio);
    greth->phyaddr = ((tmp >> 11) & 0x1F);
    
    greth->txd = (struct descriptor *) almalloc(1024);
    greth->rxd = (struct descriptor *) almalloc(1024);
    save((int)&greth->regs->tx_desc_p, (unsigned int) greth->txd);
    save((int)&greth->regs->rx_desc_p, (unsigned int) greth->rxd);

    /* Reset PHY */
    if (greth->edcl == 0) {
            write_mii(greth->phyaddr, 0, 0x8000, greth->regs);
            while ( (tmp=read_mii(greth->phyaddr,0, greth->regs)) & 0x8000)
                    ;
            i = 0;
            if (tmp & 0x1000) { /* auto neg */
                    while ( !(read_mii(greth->phyaddr,1, greth->regs) & 0x20 ) ) {
                            i++;
                            if (i > 50000) {
                                    /* printf("Auto-negotiation failed\n"); */
                                    break;
                            }
                    }
            }
            tmp = read_mii(greth->phyaddr, 0, greth->regs);

            if (greth->gbit && !(tmp >> 13) && (tmp >> 6)) {
                    gbit = 1; speed = 0;
            } else if ((tmp >> 13) && !(tmp >> 6)) {
                    gbit = 0; speed = 1;
            } else if (!(tmp >> 13) && !(tmp >> 6)) {
                    gbit = 0; speed = 0;
            }
            duplex = (tmp >> 8) & 1;
            
            save((int)&greth->regs->control, (duplex << 4) || (speed << 7) || (gbit << 8));
    } else {
            /* wait for edcl phy initialisation to finish */
            i = 0;
            
            while (i < 3) {
                    tmp = load((int)&greth->regs->mdio);
                    if ((tmp >> 3) & 1) {
                            i = 0;
                    } else {
                            i++;
                    }
            }
            
            
    }
    
    
    
    
    /* printf("GRETH(%s) Ethernet MAC at [0x%x]. Running %d Mbps %s duplex\n", greth->gbit?"10/100/1000":"10/100" , \ */
/*                                                          (unsigned int)(greth->regs),  \ */
/*                                                          (speed == 0x2000) ? 100:10, duplex ? "full":"half"); */
    
    greth_set_mac_address(greth, greth->esa);

}

inline int greth_tx(int size, char *buf, struct greth_info *greth) 
{
    if ((load((int)&(greth->txd[greth->txpnt].ctrl)) >> 11) & 1) {
        return 0;
    }

    greth->txd[greth->txpnt].addr = (int) buf;
 
    if (greth->txpnt == 127) {
        greth->txd[greth->txpnt].ctrl =  GRETH_BD_WR | GRETH_BD_EN | size;
        greth->txpnt = 0;
    } else {
        greth->txd[greth->txpnt].ctrl = GRETH_BD_EN | size;
        greth->txpnt++;
    }

    greth->regs->control = load((int)&(greth->regs->control)) | GRETH_TXEN;
  
    return 1;
}

inline int greth_rx(char *buf, struct greth_info *greth) 
{
    if (((load((int)&(greth->rxd[greth->rxpnt].ctrl)) >> 11) & 1)) {
        return 0;
    }
    greth->rxd[greth->rxpnt].addr = (int)buf;
    if (greth->rxpnt == 127) {
        greth->rxd[greth->rxpnt].ctrl = GRETH_BD_WR | GRETH_BD_EN;
        greth->rxpnt = 0;
    } else {  
        greth->rxd[greth->rxpnt].ctrl = GRETH_BD_EN;
        greth->rxpnt++;
    }
    greth->regs->control = load((int)&(greth->regs->control)) | GRETH_RXEN;
    return 1;
}

inline int greth_checkrx(int *size, struct rxstatus *rxs, struct greth_info *greth) 
{
    int tmp;
    tmp = load((int)&(greth->rxd[greth->rxchkpnt].ctrl));
    if (!((tmp >> 11) & 1)) {
        *size = tmp & GRETH_BD_LEN;
        if (greth->rxchkpnt == 127) {
            greth->rxchkpnt = 0;
        } else {
            greth->rxchkpnt++;
        }
        return 1;
    } else {
        return 0;
    }
}

inline int greth_checktx(struct greth_info *greth)
{
  int tmp;
  tmp = load((int)&(greth->txd[greth->txchkpnt].ctrl));
  if (!((tmp >> 11) & 1)) {
    if (greth->txchkpnt == 127) {
      greth->txchkpnt = 0;
    } else {
      greth->txchkpnt++;
    }
    return 1;
  } else {
      return 0;
  }
}
