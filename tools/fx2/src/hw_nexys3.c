/* $Id: hw_nexys3.c 447 2011-12-31 19:41:32Z mueller $ */
/*
 * Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
 * Code was forked from ixo-jtag.svn.sourceforge.net on 2011-07-17
 *
 * - original copyright and licence disclaimer --------------------------------
 * - Copyright (C) 2007 Kolja Waschk, ixo.de
 * - This code is part of usbjtag. usbjtag is free software;
 * - This code was copied from hw_basic.c and adapted for the Digilent Nexys(2) 
 * - boards by Sune Mai (Oct 2008) with minor cleanups by Hauke Daempfling 
 * - (May 2010). See http://www.fpga4fun.com/forum/viewtopic.php?t=483&start=50
 * ----------------------------------------------------------------------------
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
 * ----------------------------------------------------------------------------
 * Hardware-dependent code for usb_jtag
 *
 * Revision History:
 * 
 * Date         Rev Version  Comment
 * 2011-12-30   447   1.0.1  move JTAG pin OE intoProgIO_Set_State()
 * 2011-12-29   446   1.0    Initial version (adapt&cleanup from hw_nexys2.c)
 * 
 *-----------------------------------------------------------------------------
 */

#include <fx2regs.h>
#include "hardware.h"
#include "delay.h"

//-----------------------------------------------------------------------------

/* JTAG TCK, AS/PS DCLK */

sbit at 0xB4          TCK; /* Port D.4 */
#define bmTCKOE       bmBIT4
#define SetTCK(x)     do{TCK=(x);}while(0)

/* JTAG TDI, AS ASDI, PS DATA0 */

sbit at 0xB2          TDI; /* Port D.2 */
#define bmTDIOE       bmBIT2
#define SetTDI(x)     do{TDI=(x);}while(0)

/* JTAG TMS, AS/PS nCONFIG */

sbit at 0xB3          TMS; /* Port D.3 */
#define bmTMSOE       bmBIT3
#define SetTMS(x)     do{TMS=(x);}while(0)

/* JTAG TDO, AS/PS CONF_DONE */

sbit at 0xB0          TDO; /* Port D.0 */
#define bmTDOOE       bmBIT0 
#define GetTDO(x)     TDO

//-----------------------------------------------------------------------------

#define bmPROGOUTOE (bmTCKOE|bmTDIOE|bmTMSOE)
#define bmPROGINOE  (bmTDOOE)

//-----------------------------------------------------------------------------

void ProgIO_Poll(void)    {}
void ProgIO_Enable(void)  {}
// These aren't called anywhere in usbjtag.c so far, might come...
void ProgIO_Disable(void) {}
void ProgIO_Deinit(void)  {}


void ProgIO_Init(void)
{
  /* The following code depends on your actual circuit design.
     Make required changes _before_ you try the code! */

  // Note: JTAG signal output enables are in ProgIO_Set_State() below.

  mdelay(500);                              // wait for supply to come up

}

void ProgIO_Set_State(unsigned char d)
{
  /* Set state of output pins:
   *
   * d.0 => TCK
   * d.1 => TMS
   * d.4 => TDI
   */

  // JTAG signal output enables done at first request:
  //   this allows to use the JTAG connector with another JTAG cable
  //   alternatively.
  OED=(OED&~bmPROGINOE) | bmPROGOUTOE; // Output enable

  SetTCK((d & bmBIT0) ? 1 : 0);
  SetTMS((d & bmBIT1) ? 1 : 0);
  SetTDI((d & bmBIT4) ? 1 : 0);
}

//-----------------------------------------------------------------------------
// dummied AS/PS code
#define GetASDO(x)  1

unsigned char ProgIO_Set_Get_State(unsigned char d)
{
  /* Set state of output pins (s.a.)
   * then read state of input pins:
   *
   * TDO => d.0
   * DATAOUT => d.1 (only #ifdef HAVE_AS_MODE)
   */

  ProgIO_Set_State(d);
  return (GetASDO()<<1)|GetTDO();
}

//-----------------------------------------------------------------------------

void ProgIO_ShiftOut(unsigned char c)
{
  /* Shift out byte C: 
   *
   * 8x {
   *   Output least significant bit on TDI
   *   Raise TCK
   *   Shift c right
   *   Lower TCK
   * }
   */
 
  (void)c; /* argument passed in DPL */

  _asm
        MOV  A,DPL
        ;; Bit0
        RRC  A
        MOV  _TDI,C
        SETB _TCK
        ;; Bit1
        RRC  A
        CLR  _TCK
        MOV  _TDI,C
        SETB _TCK
        ;; Bit2
        RRC  A
        CLR  _TCK
        MOV  _TDI,C
        SETB _TCK
        ;; Bit3
        RRC  A
        CLR  _TCK
        MOV  _TDI,C
        SETB _TCK
        ;; Bit4
        RRC  A
        CLR  _TCK
        MOV  _TDI,C
        SETB _TCK
        ;; Bit5
        RRC  A
        CLR  _TCK
        MOV  _TDI,C
        SETB _TCK
        ;; Bit6
        RRC  A
        CLR  _TCK
        MOV  _TDI,C
        SETB _TCK
        ;; Bit7
        RRC  A
        CLR  _TCK
        MOV  _TDI,C
        SETB _TCK
        NOP 
        CLR  _TCK
        ret
  _endasm;
}

/*
;; For ShiftInOut, the timing is a little more
;; critical because we have to read _TDO/shift/set _TDI
;; when _TCK is low. But 20% duty cycle at 48/4/5 MHz
;; is just like 50% at 6 Mhz, and that's still acceptable
*/

unsigned char ProgIO_ShiftInOut(unsigned char c)
{
  /* Shift out byte C, shift in from TDO:
   *
   * 8x {
   *   Read carry from TDO
   *   Output least significant bit on TDI
   *   Raise TCK
   *   Shift c right, append carry (TDO) at left
   *   Lower TCK
   * }
   * Return c.
   */

   (void)c; /* argument passed in DPL */

  _asm
        MOV  A,DPL

        ;; Bit0
        MOV  C,_TDO
        RRC  A
        MOV  _TDI,C
        SETB _TCK
        CLR  _TCK
        ;; Bit1
        MOV  C,_TDO
        RRC  A
        MOV  _TDI,C
        SETB _TCK
        CLR  _TCK
        ;; Bit2
        MOV  C,_TDO
        RRC  A
        MOV  _TDI,C
        SETB _TCK
        CLR  _TCK
        ;; Bit3
        MOV  C,_TDO
        RRC  A
        MOV  _TDI,C
        SETB _TCK
        CLR  _TCK
        ;; Bit4
        MOV  C,_TDO
        RRC  A
        MOV  _TDI,C
        SETB _TCK
        CLR  _TCK
        ;; Bit5
        MOV  C,_TDO
        RRC  A
        MOV  _TDI,C
        SETB _TCK
        CLR  _TCK
        ;; Bit6
        MOV  C,_TDO
        RRC  A
        MOV  _TDI,C
        SETB _TCK
        CLR  _TCK
        ;; Bit7
        MOV  C,_TDO
        RRC  A
        MOV  _TDI,C
        SETB _TCK
        NOP
        CLR  _TCK

        MOV  DPL,A
        ret
  _endasm;

  /* return value in DPL */

  return c;
}


