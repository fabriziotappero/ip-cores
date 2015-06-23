/* $Id: usb_fifo_init.c 450 2012-01-05 23:21:41Z mueller $ */
/*
 * Copyright 2011-2012 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
 * Code was forked from ixo-jtag.svn.sourceforge.net on 2011-07-17
 * The data fifo treatment is partially inspired by work of Marco Oster
 * done at ZITI, Heidelberg in 2010.
 *
 * - original copyright and licence disclaimer (of usb_jtag_init) -------------
 * - Code that turns a Cypress FX2 USB Controller into an USB JTAG adapter
 * - Copyright (C) 2005..2007 Kolja Waschk, ixo.de
 * - This code is part of usbjtag. usbjtag is free software;
 *-----------------------------------------------------------------------------
 * 
 * This program is free software; you may redistribute and/or modify it under
 * the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 2, or at your option any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for complete details.
 *  
 *-----------------------------------------------------------------------------
 *
 * USB FIFO setup
 *
 * Revision History:
 * 
 * Date         Rev Version  Comment
 * 2012-01-04   450   1.5    new FLAGS layout (D=8-FF,C=4-EF,B=6-FF,A=indexed)
 * 2012-01-02   448   1.4    add support for sync fifo w/ int. clock (_ic)
 * 2011-07-24   398   1.1    support 0,2, or 3 data FIFO's
 * 2011-07-23   397   1.0    Initial version, factored out from usb_jtag_init()
 *
 *-----------------------------------------------------------------------------
 */

#include "fx2regs.h"
#include "syncdelay.h"

//-----------------------------------------------------------------------------

void usb_fifo_init(void)                // Called once at startup
{
  // set the CPU clock to 48MHz, enable USB clock output to FPGA
  // Note: CLKOUT not connected on nexys2, nexys3 and atlys...
  CPUCS = bmCLKOE | bmCLKSPD1;

  // setup FIFO mode
  //   bmIFCLKSRC   clock source: 0 external clock; 1 internal clock
  //   bm3048MHZ    clock frequency: 0 30 MHz; 1 48 MHz
  //   bmIFCLKOE    IFCLK pin output enable: 0 tri-state; 1 drive
  //   bmIFCLKPOL   clock polarity: 0 rising edge active; 1 falling edge active
  //   bmASYNC      fifo mode: 0 synchrounous; 1 asynchronous
  //   IFCFG        interface mode: bmIFCFGMASK=11->slave fifo

#if defined(USE_IC30)
  // Use internal 30 MHz, enable output, slave sync FIFO, slave FIFO mode
  IFCONFIG = bmIFCLKSRC | bmIFCLKOE | bmIFCFGMASK;
#else
  // Use internal 30 MHz, enable output, slave async FIFO, slave FIFO mode
  IFCONFIG = bmIFCLKSRC | bmIFCLKOE | bmASYNC | bmIFCFGMASK;
#endif

  // Setup PA7 as FLAGD
  PORTACFG = 0x80;   SYNCDELAY;        // 1000 0000: FLAGD=1, SLCS=0

  // setup usage of FLAG pins
  // goal is to support EP4(out) and EP6/EP8(in) synchronous slave fifos
  // for synchronous operation usage of empty/full and almost empty/full
  // flags is needed, the later are realized with the programmable flags.
  // the three empty/full flags are setup as fixed flags, while the three
  // almost (or programmable) flags are channeled over one indexed flag pin.
  //    FLAGA = indexed, PF (the default)
  //    FLAGB = EP6 FF
  //    FLAGC = EP4 EF
  //    FLAGD = EP8 FF

  PINFLAGSAB = 0xE0; SYNCDELAY;         // 1110 0000: B EP6 FF,  A indexed
  PINFLAGSCD = 0xF9; SYNCDELAY;         // 1111 1001: D EP8 FF,  C EP4 EF

  // define endpoint configuration

  FIFORESET  = 0x80; SYNCDELAY;         // From now on, NAK all
  REVCTL     = 3;    SYNCDELAY;         // Allow FW access to FIFO buffer

  // FIFOs used for JTAG emulation
  //   EP1 IN
  //   EP2 OUT

  EP1OUTCFG  = 0x00; SYNCDELAY;         // EP1 OUT: inactive
  EP1INCFG   = 0xA0; SYNCDELAY;         // EP1 IN:  active, bulk
  
  EP2FIFOCFG = 0x00; SYNCDELAY;         // EP2 slave: 0, not used as slave
  FIFORESET  = 0x02; SYNCDELAY;         // EP2 reset (0x02! see comment below)
  EP2CFG     = 0xA2; SYNCDELAY;         // EP2: 1010 0010: VAL,OUT,BULK,DOUBLE

  // TMR (Rev *D) page 117: auto in/out initialization sequence
  //   Auto IN transfers
  //     1. setup EPxCFG
  //     2. reset the FIFO
  //     3. set   EPxFIFOCFG.3 = 1
  //     4. set   EPxAUTOINLENH:L
  //   Auto OUT transfers
  //     1. setup EPxCFG
  //     2. reset the FIFO
  //     3. arm OUT buffers by writing OUTPKTEND N times w/ skip=1 (N=buf depth)
  //     4. set   EPxFIFOCFG.4 = 1

  // 2 FIFOs used for DATA transfer:
  //   EP4 OUT  DOUBLE
  //   EP6 IN   QUAD

#if defined(USE_2FIFO) || defined(USE_3FIFO)
  EP4CFG     = 0xA2; SYNCDELAY;         // EP4: 1010 0010: VAL,OUT,BULK,DOUBLE
#if defined(USE_3FIFO)
  EP6CFG     = 0xE2; SYNCDELAY;         // EP6: 1110 0010: VAL,IN,BULK,DOUBLE
  EP8CFG     = 0xE2; SYNCDELAY;         // EP8: 1110 0010: VAL,IN,BULK,DOUBLE
#else
  EP6CFG     = 0xE0; SYNCDELAY;         // EP6: 1110 0000: VAL,IN,BULK,QUAD
  EP8CFG     = 0x02; SYNCDELAY;         // EP8: disabled
#endif

  // Note: the description of the FIFORESET in the TMR, Rev *D (2011) is
  //       wrong. The TMR asks to write 0x80,0x82,0x84,0x86,0x88,0x00, e.g
  //       on page 117, also in other contexts.
  //       This doesn't work, FIFO's are in fact not reset !
  //       The proper sequence is 0x80,0x02,0x04,0x06,0x08,0x00, as for
  //       example stated in http://www.cypress.com/?id=4&rID=32093
  FIFORESET  = 0x04; SYNCDELAY;         // EP4 reset
  FIFORESET  = 0x06; SYNCDELAY;         // EP6 reset
  FIFORESET  = 0x08; SYNCDELAY;         // EP8 reset
  FIFORESET  = 0x00; SYNCDELAY;         // Restore normal behaviour

  // !! really needed here, before buffers are armed !!
  REVCTL     = 0;    SYNCDELAY;         // Reset FW access to FIFO buffer

  // EP4 OUT setup ---------------------------------------------------
  OUTPKTEND  = 0x84; SYNCDELAY;         // arm all EP4 buffers
  OUTPKTEND  = 0x84; SYNCDELAY;
  // !! hardware only arms endpoint when AUTOOUT 0->1 transition seen
  // !! --> clean AUTOOUT to handle for example back-to-back firmware loads
  EP4FIFOCFG = 0x00; SYNCDELAY;         // EP4: force AUTOOUT 0->1 transition
  EP4FIFOCFG = 0x10; SYNCDELAY;         // EP4: 0001 0000: AUTOOUT, BYTE
  //   setup programmable fifo threshold as 'almost empty' at 3 bytes to go
  //   --> keep active low logic for prgrammable flags
  //   --> set flag 1 when fill >= threshold (DECIS=1)
  //   -->   almost empty thus at fill<4, effective threshold thus 3 !!
  EP4FIFOPFH = 0x80; SYNCDELAY;         // 0000 0000: DECIS=1, PFC8=0
  EP4FIFOPFL = 0x04; SYNCDELAY;         // PFC =   4 = 0 0000 0100

  // EP6 IN  setup ---------------------------------------------------
  EP6FIFOCFG = 0x0C; SYNCDELAY;         // EP6: 0000 1100: AUTOIN, ZEROLEN, BYTE
  EP6AUTOINLENH = 0x02; SYNCDELAY;      //   512 byte buffers
  EP6AUTOINLENL = 0x00; SYNCDELAY;

  //   setup programmable fifo threshold as 'almost full' at 3 bytes to go
  //   --> keep active low logic for prgrammable flags
  //   --> set flag 1 when fill <= threshold (DECIS=0)
  //   -->   use full buffer fill
  //   -->     for dual buffered: (PKSTAT=0, PKTS=1)   [in case 3 fifo's used]
  //   -->     for quad buffered: (PKSTAT=0, PKTS=3)   [in case 2 fifo's used]
  //   -->   effective threshold thus 3 in both bases
#if defined(USE_3FIFO)
  EP6FIFOPFH = 0x09; SYNCDELAY;         // 0000 1001: DECIS=0, PK=0:1, PFC8=1
#else
  EP6FIFOPFH = 0x19; SYNCDELAY;         // 0001 1001: DECIS=0, PK=0:3, PFC8=1
#endif
  EP6FIFOPFL = 0xfc; SYNCDELAY;         // PFC = 508 = 1 1111 1100

#if defined(USE_3FIFO)
  // EP8 IN  setup ---------------------------------------------------
  EP8FIFOCFG = 0x0C; SYNCDELAY;         // EP8: 0000 1100: AUTOIN, ZEROLEN, BYTE
  EP8AUTOINLENH = 0x02; SYNCDELAY;      //   512 byte buffers
  EP8AUTOINLENL = 0x00; SYNCDELAY;
  //   setup programmable fifo threshold as 'almost full' at 4 bytes to go
  //   like for EP6 above
  EP8FIFOPFH = 0x41; SYNCDELAY;         // 0100 0001: DECIS=0, PKSTAT=1, PFC8=1
  EP8FIFOPFL = 0xfc; SYNCDELAY;         // PFC = 508 = 1 1111 1100

#else
  // EP8 setup
  EP8FIFOCFG = 0x00; SYNCDELAY;         // EP8 slave: 0, not used as slave
#endif

#else
  // no FIFOs used for DATA transfer
  //   EP4,6,8 inactive
  EP4CFG     = 0x02; SYNCDELAY;         // EP4: disabled
  EP6CFG     = 0x02; SYNCDELAY;         // EP6: disabled
  EP8CFG     = 0x02; SYNCDELAY;         // EP8: disabled

  FIFORESET  = 0x04; SYNCDELAY;         // EP4 reset
  FIFORESET  = 0x06; SYNCDELAY;         // EP6 reset
  FIFORESET  = 0x08; SYNCDELAY;         // EP8 reset
  FIFORESET  = 0x00; SYNCDELAY;         // Restore normal behaviour

  EP4FIFOCFG = 0x00; SYNCDELAY;         // EP4 slave: 0, not used as slave
  EP6FIFOCFG = 0x00; SYNCDELAY;         // EP6 slave: 0, not used as slave
  EP8FIFOCFG = 0x00; SYNCDELAY;         // EP8 slave: 0, not used as slave

  REVCTL     = 0;    SYNCDELAY;         // Reset FW access to FIFO buffer
#endif

  // the EP2 endpoint does not come up armed. It is used with double buffering 
  // so write dummy byte counts twice.
  SYNCDELAY;                    // 
  EP2BCL = 0x80;     SYNCDELAY;         // arm EP2OUT
  EP2BCL = 0x80;     SYNCDELAY;         // arm EP2OUT
}
