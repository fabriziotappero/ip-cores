/*----------------------------------------------------------------
//                                                              //
//  boot-loader-ethmac.c                                        //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  The main functions for the boot loader application. This    //
//  application is embedded in the FPGA's SRAM and is used      //
//  to load larger applications into the DDR3 memory on         //
//  the development board.                                      //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2011 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
----------------------------------------------------------------*/


#include "amber_registers.h"
#include "address_map.h"
#include "timer.h"
#include "utilities.h"
#include "line-buffer.h"
#include "packet.h"
#include "ethmac.h"


/* open a link */
void init_ethmac()
{
    /* initialize the packet rx buffer */
    init_packet();

    /* open ethernet port and wait for connection requests
       keep trying forever */
    while (!open_link());
}



/* return 1 if link comes up */
int open_link (void)
{
    int packet;
    int n;
    unsigned int d32;

    /* Disable Ethmac interrupt in interrupt controller */
    *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLECLR ) = 0x100;

    /* Set my MAC address */
    d32 = self_g.mac[2]<<24|self_g.mac[3]<<16|self_g.mac[4]<<8|self_g.mac[5];
    *(unsigned int *) ( ADR_ETHMAC_MAC_ADDR0 ) = d32;

    d32 = self_g.mac[0]<<8|self_g.mac[1];
    *(unsigned int *) ( ADR_ETHMAC_MAC_ADDR1 ) = d32;

    if (!init_phy())
        return 0;

    /* Write the Receive Packet Buffer Descriptor */
    /* Buffer Pointer */
    for (packet=0; packet<ETHMAC_RX_BUFFERS; packet++) {
        *(unsigned int *) ( ADR_ETHMAC_BDBASE + 0x204 + packet*8 ) = ETHMAC_RX_BUFFER + packet * 0x1000;
        /* Ready Rx buffer
           [31:16] = length in bytes,
           [15] = empty
           [14] = Enable IRQ
           [13] = wrap bit */
        /* set empty flag again */
        if (packet == ETHMAC_RX_BUFFERS-1) /* last receive buffer ? */
            /* Set wrap bit is last buffer */
            *(unsigned int *) ( ADR_ETHMAC_BDBASE + 0x200 + packet*8 ) = 0x0000e000;
        else
            *(unsigned int *) ( ADR_ETHMAC_BDBASE + 0x200 + packet*8 ) = 0x0000c000;
        }


    /* Enable EthMac interrupts in Ethmac core */
    /* Receive frame and receive error botgh enabled */
    /* When a bad frame is received is still gets written to a buffer
       so needs to be dealt with */
    *(unsigned int *) ( ADR_ETHMAC_INT_MASK ) = 0xc;

    /* Enable Ethmac interrupt in interrupt controller */
    *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLESET ) = 0x100;

    /* Set transmit packet buffer location */
    *(unsigned int *) ( ADR_ETHMAC_BDBASE + 4 ) = ETHMAC_TX_BUFFER;

    /* Set the ready bit, bit 15, low */
    *(unsigned int *) ( ADR_ETHMAC_BDBASE + 0 ) = 0x7800;

    /* Enable Rx & Tx - MODER Register
     [15] = Add pads to short frames
     [13] = CRCEN
     [10] = Enable full duplex
     [7]  = loopback
     [5]  = 1 for promiscuous, 0 rx only frames that match mac address
     [1]  = txen
     [0]  = rxen  */
    *(unsigned int *) ( ADR_ETHMAC_MODER ) = 0xa423;

    return 1;
}



void close_link (void)
{
    /* Disable EthMac interrupts in Ethmac core */
    *(unsigned int *) ( ADR_ETHMAC_INT_MASK ) = 0x0;

    /* Disable Ethmac interrupt in interrupt controller */
    *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLECLR ) = 0x100;

    /* Disable Rx & Tx - MODER Register
     [15] = Add pads to short frames
     [13] = CRCEN
     [10] = Enable full duplex
     [7]  = loopback
     [5]  = 1 for promiscuous, 0 rx only frames that match mac address
     [1]  = txen
     [0]  = rxen  */
    *(unsigned int *) ( ADR_ETHMAC_MODER ) = 0xa420;

    /* Put the PHY into reset */
    phy_rst(0);  /* reset is active low */

}


void ethmac_tx_packet(char* buf, int len)
{
    unsigned int status = 0;

    /* copy the packet into the tx buffer */
    strncpy((char*)ETHMAC_TX_BUFFER, buf, len);


    /* Poll the ready bit.
       Wait until the ready bit is cleared by the ethmac hardware
       This holds everything up while the packet is being transmitted, but
       it keeps things simple. */
    status = *(volatile unsigned int *) ( ADR_ETHMAC_BDBASE + 0 );
    while ((status & 0x8000) != 0) {
        udelay20();
        status = *(volatile unsigned int *) ( ADR_ETHMAC_BDBASE + 0 );
        }


    /* Enable packet tx
       [31:16] = length in bytes,
       [15] = ready
       [14] = tx int
       [13] = wrap bit
       [12] = pad enable for short packets
       [11] = crc en
    */
    *(unsigned int *) ( ADR_ETHMAC_BDBASE + 0 ) = len<<16 | 0xf800;
}



/* returns 1 if link comes up */
int init_phy (void)
{
    int addr;
    int bmcr;
    int stat;
    int phy_id;
    int link_up = 1;
    time_t* link_timer;

    link_timer = new_timer();

    /* Bring PHY out of reset */
    phy_rst(1);  /* reset is active low */

    /* Discover phy addr by searching addrs in order {1,0,2,..., 31} */
    for(addr = 0; addr < 32; addr++) {
            phy_id = (addr == 0) ? 1 : (addr == 1) ? 0 : addr;
            bmcr = mdio_read(phy_id, MII_BMCR);  /* Basic Mode Control Register */
            stat = mdio_read(phy_id, MII_BMSR);
            stat = mdio_read(phy_id, MII_BMSR);
            if(!((bmcr == 0xFFFF) || ((stat == 0) && (bmcr == 0))))
                break;
    }
    /* Failed to find a PHY on the md bus */
    if (addr == 32)
        return 0;

    /* Reset PHY */
    bmcr = mdio_read(phy_id, MII_BMCR);
    mdio_write(phy_id, MII_BMCR, bmcr | BMCR_RESET);

    /* Advertise that PHY is NOT B1000-T capable */
    /* Set bits 9.8, 9.9 to 0 */
    bmcr = mdio_read(phy_id, MII_CTRL1000);
    mdio_write(phy_id, MII_CTRL1000, bmcr & 0xfcff );

    /* Restart autoneg */
    bmcr = mdio_read(phy_id, MII_BMCR);
    mdio_write(phy_id, MII_BMCR, bmcr | BMCR_ANRESTART);

    /* Wait for link up */
    /* Print PHY status MII_BMSR = Basic Mode Status Register*/
    /* allow a few seconds for the link to come up before giving up */
    set_timer(link_timer, 5000);

    while (!((stat = mdio_read(phy_id, MII_BMSR)) & BMSR_LSTATUS)) {
        if (timer_expired(link_timer)) {
            link_up = 0;
            break;
            }
        }

    return link_up;
}


int mdio_read(int addr, int reg)
{
    return mdio_ctrl(addr, mdi_read, reg, 0);
}


void mdio_write(int addr, int reg, int data)
{
    mdio_ctrl(addr, mdi_write, reg, data);
}


/*
 addr = PHY address
 reg  = register address within PHY
 */
unsigned short mdio_ctrl(unsigned int addr, unsigned int dir, unsigned int reg, unsigned short data)
{
    unsigned int data_out = 0;
    unsigned int i;
    unsigned long flags;

    mdio_ready();

    *(volatile unsigned int *)(ADR_ETHMAC_MIIADDRESS) = (reg << 8) | (addr & 0x1f);

    if (dir == mdi_write) {
        *(volatile unsigned int *)(ADR_ETHMAC_MIITXDATA) = data;
        /* Execute Write ! */
        *(volatile unsigned int *)(ADR_ETHMAC_MIICOMMAND) = 0x4;
    }
    else {
        /* Execute Read ! */
        *(volatile unsigned int *)(ADR_ETHMAC_MIICOMMAND) = 0x2;
        mdio_ready();
        data_out = *(volatile unsigned int *)(ADR_ETHMAC_MIIRXDATA);
    }

    return (unsigned short) data_out;
}


/* Wait until its ready */
void mdio_ready()
{
    int i;
    for (;;) {
        /* Bit 1 is high when the MD i/f is busy */
        if ((*(volatile unsigned int *)(ADR_ETHMAC_MIISTATUS) & 0x2) == 0x0)
            break;

        i++;
        if (i==10000000) {
            i=0;
            }
        }
}



void ethmac_interrupt(void)
{
    int buffer;
    unsigned int int_src;
    unsigned int rx_buf_status;

    /* Mask ethmac interrupts */
    *(volatile unsigned int *) ( ADR_ETHMAC_INT_MASK   ) = 0;

    int_src = *(volatile unsigned int *) ( ADR_ETHMAC_INT_SOURCE );

    if (int_src) {
        for (buffer=0; buffer<ETHMAC_RX_BUFFERS; buffer++) {

           rx_buf_status = *(volatile unsigned int *) ( ADR_ETHMAC_BDBASE + 0x200 + buffer*8 );

           if ((rx_buf_status & 0x8000) == 0) {
                parse_rx_packet((char*)(ETHMAC_RX_BUFFER+buffer*0x1000), rx_packet_g);

                /* set empty flag again */
                if (buffer == ETHMAC_RX_BUFFERS-1) /* last receive buffer ? */
                    *(unsigned int *) ( ADR_ETHMAC_BDBASE + 0x200 + buffer*8 ) = 0x0000e000;
                else
                    *(unsigned int *) ( ADR_ETHMAC_BDBASE + 0x200 + buffer*8 ) = 0x0000c000;
                }
            }
        }

    /* Clear all ethmac interrupts */
    *(volatile unsigned int *) ( ADR_ETHMAC_INT_SOURCE ) = int_src;

    /* UnMask ethmac interrupts */
    *(volatile unsigned int *) ( ADR_ETHMAC_INT_MASK   ) = 0xc;
}


