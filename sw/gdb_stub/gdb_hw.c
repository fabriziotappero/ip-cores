//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.0
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2014 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------
#include "mem_map.h"
#include "gdb_hw.h"

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
#define UART_RX_AVAIL    (1<<0)
#define UART_TX_AVAIL    (1<<1)
#define UART_RX_FULL     (1<<2)
#define UART_TX_BUSY     (1<<3)
#define UART_RX_ERROR    (1<<4)

// SR Register
#define SPR_SR                  (17)
#define SPR_SR_ICACHE_FLUSH     (1 << 17)
#define SPR_SR_DCACHE_FLUSH     (1 << 18)

#define MAX_RX_BUF      128
static char _rx_buf[MAX_RX_BUF];
static int _rx_head;
static int _rx_tail;

//-----------------------------------------------------------------
// mfspr: Read from SPR
//-----------------------------------------------------------------
static inline unsigned long mfspr(unsigned long spr) 
{    
    unsigned long value;
    asm volatile ("l.mfspr\t\t%0,%1,0" : "=r" (value) : "r" (spr));
    return value;
}
//-----------------------------------------------------------------
// mtspr: Write to SPR
//-----------------------------------------------------------------
static inline void mtspr(unsigned long spr, unsigned long value) 
{
    asm volatile ("l.mtspr\t\t%0,%1,0": : "r" (spr), "r" (value));
}
//-----------------------------------------------------------------
// gdb_pollrx:
//-----------------------------------------------------------------
void gdb_pollrx (void)
{    
    if (UART_USR & UART_RX_AVAIL)
    {
        _rx_buf[_rx_tail] = UART_UDR;

        if (++_rx_tail == MAX_RX_BUF)
            _rx_tail = 0;
    }
}
//-----------------------------------------------------------------
// gdb_putchar:
//-----------------------------------------------------------------
void gdb_putchar (char c)
{
    UART_UDR = c;
    while (UART_USR & UART_TX_BUSY)
        gdb_pollrx();
}
//-------------------------------------------------------------
// gdb_putstr:
//-------------------------------------------------------------
void gdb_putstr(const char *str)
{
    while (*str)
        gdb_putchar(*str++);
}
//-----------------------------------------------------------------
// gdb_getchar:
//-----------------------------------------------------------------
int gdb_getchar (void)
{
    int ch = -1;

    do
    {
        gdb_pollrx();

        if (_rx_head != _rx_tail)
        {
            ch = _rx_buf[_rx_head];

            if (++_rx_head == MAX_RX_BUF)
                _rx_head = 0;

            break;
        }
    }
    while (1);

    return ch;
}
//-----------------------------------------------------------------
// gdb_flush_cache:
//-----------------------------------------------------------------
void gdb_flush_cache(void)
{
    mtspr(SPR_SR, mfspr(SPR_SR) | SPR_SR_ICACHE_FLUSH | SPR_SR_DCACHE_FLUSH);
}
