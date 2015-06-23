//---------------------------------------------------------------------------
// Copyright (C) 2001 Dallas Semiconductor Corporation, All Rights Reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY,  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL DALLAS SEMICONDUCTOR BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// Except as contained in this notice, the name of Dallas Semiconductor
// shall not be used except as stated in the Dallas Semiconductor
// Branding Policy.
//---------------------------------------------------------------------------
//
//  TODO.C - Link Layer functions required by general 1-Wire drive
//           implementation.  Fill in the platform specific code.
//
//  Version: 3.00
//
//  History: 1.00 -> 1.01  Added function msDelay.
//           1.02 -> 1.03  Added function msGettick.
//           1.03 -> 2.00  Changed 'MLan' to 'ow'. Added support for
//                         multiple ports.
//           2.10 -> 3.00  Added owReadBitPower and owWriteBytePower
//

#include "ownet.h"
#include "sockit_owm_regs.h"
#include "sockit_owm.h"
#include <unistd.h>

extern sockit_owm_state sockit_owm;

// exportable link-level functions
SMALLINT owTouchReset(int);
SMALLINT owTouchBit(int,SMALLINT);
SMALLINT owTouchByte(int,SMALLINT);
SMALLINT owWriteByte(int,SMALLINT);
SMALLINT owReadByte(int);
SMALLINT owSpeed(int,SMALLINT);
SMALLINT owLevel(int,SMALLINT);
SMALLINT owProgramPulse(int);
void msDelay(int);
long msGettick(void);
SMALLINT owWriteBytePower(int,SMALLINT);
SMALLINT owReadBytePower(int);
SMALLINT owReadBitPower(int,SMALLINT);
SMALLINT owHasPowerDelivery(int);
SMALLINT owHasOverDrive(int);
SMALLINT owHasProgramPulse(int);

//--------------------------------------------------------------------------
// Reset all of the devices on the 1-Wire Net and return the result.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number is provided to
//                indicate the symbolic port number.
//
// Returns: TRUE(1):  presence pulse(s) detected, device(s) reset
//          FALSE(0): no presence pulses detected
//
SMALLINT owTouchReset(int portnum)
{
   int reg;
   int ovd = (sockit_owm.ovd >> portnum) & 0x1;

   // lock transfer
   ALT_SEM_PEND (sockit_owm.cyc, 0);

   // reset pulse
   IOWR_SOCKIT_OWM_CTL (sockit_owm.base, (sockit_owm.pwr << SOCKIT_OWM_CTL_POWER_OFST    )
                                       | (portnum        << SOCKIT_OWM_CTL_SEL_OFST      )
                                       | (sockit_owm.ien  ? SOCKIT_OWM_CTL_IEN_MSK : 0x00)
                                       | (                  SOCKIT_OWM_CTL_CYC_MSK       )
                                       | (ovd             ? SOCKIT_OWM_CTL_OVD_MSK : 0x00)
                                       | (                  SOCKIT_OWM_CTL_RST_MSK       ));

   // wait for irq to set the transfer end flag
   ALT_FLAG_PEND (sockit_owm.irq, 0x1, OS_FLAG_WAIT_SET_ANY + OS_FLAG_CONSUME, 0);
   // wait for STX (end of transfer cycle) and read the presence status
   while ((reg = IORD_SOCKIT_OWM_CTL (sockit_owm.base)) & SOCKIT_OWM_CTL_CYC_MSK);

   // release transfer lock
   ALT_SEM_POST (sockit_owm.cyc);

   // return negated DAT (presence detect)
   return (~reg & SOCKIT_OWM_CTL_DAT_MSK);  // NOTE the shortcut
}

//--------------------------------------------------------------------------
// Send 1 bit of communication to the 1-Wire Net and return the
// result 1 bit read from the 1-Wire Net.  The parameter 'sendbit'
// least significant bit is used and the least significant bit
// of the result is the return bit.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number is provided to
//                indicate the symbolic port number.
// 'sendbit'    - the least significant bit is the bit to send
//
// Returns: 0:   0 bit read from sendbit
//          1:   1 bit read from sendbit
//
SMALLINT owTouchBit(int portnum, SMALLINT sendbit)
{
   int reg;
   int ovd = (sockit_owm.ovd >> portnum) & 0x1;

   // lock transfer
   ALT_SEM_PEND (sockit_owm.cyc, 0);

   // read/write data
   IOWR_SOCKIT_OWM_CTL (sockit_owm.base, (sockit_owm.pwr << SOCKIT_OWM_CTL_POWER_OFST    )
      	                               | (portnum        << SOCKIT_OWM_CTL_SEL_OFST      )
                                       | (sockit_owm.ien  ? SOCKIT_OWM_CTL_IEN_MSK : 0x00)
                                       | (                  SOCKIT_OWM_CTL_CYC_MSK       )
                                       | (ovd             ? SOCKIT_OWM_CTL_OVD_MSK : 0x00)
                                       | (sendbit         & SOCKIT_OWM_CTL_DAT_MSK       ));  // NOTE the shortcut

   // wait for irq to set the transfer end flag
   ALT_FLAG_PEND (sockit_owm.irq, 0x1, OS_FLAG_WAIT_SET_ANY + OS_FLAG_CONSUME, 0);
   // wait for STX (end of transfer cycle) and read the read data bit
   while ((reg = IORD_SOCKIT_OWM_CTL (sockit_owm.base)) & SOCKIT_OWM_CTL_CYC_MSK);

   // release transfer lock
   ALT_SEM_POST (sockit_owm.cyc);

   // return DAT (read bit)
   return (reg & SOCKIT_OWM_CTL_DAT_MSK);  // NOTE the shortcut
}

//--------------------------------------------------------------------------
// Send 8 bits of communication to the 1-Wire Net and return the
// result 8 bits read from the 1-Wire Net.  The parameter 'sendbyte'
// least significant 8 bits are used and the least significant 8 bits
// of the result is the return byte.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number is provided to
//                indicate the symbolic port number.
// 'sendbyte'   - 8 bits to send (least significant byte)
//
// Returns:  8 bytes read from sendbyte
//
SMALLINT owTouchByte(int portnum, SMALLINT sendbyte)
{
   int i;
   SMALLINT dat = 0;
   for (i=0; i<8; i++)
   {
      dat |= owTouchBit(portnum,sendbyte & 0x1) << i;
      sendbyte >>= 1;
   }
   return dat;
}

//--------------------------------------------------------------------------
// Send 8 bits of communication to the 1-Wire Net and verify that the
// 8 bits read from the 1-Wire Net is the same (write operation).
// The parameter 'sendbyte' least significant 8 bits are used.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number is provided to
//                indicate the symbolic port number.
// 'sendbyte'   - 8 bits to send (least significant byte)
//
// Returns:  TRUE: bytes written and echo was the same
//           FALSE: echo was not the same
//
SMALLINT owWriteByte(int portnum, SMALLINT sendbyte)
{
   return (owTouchByte(portnum,sendbyte) == sendbyte) ? TRUE : FALSE;
}

//--------------------------------------------------------------------------
// Send 8 bits of read communication to the 1-Wire Net and and return the
// result 8 bits read from the 1-Wire Net.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number is provided to
//                indicate the symbolic port number.
//
// Returns:  8 bytes read from 1-Wire Net
//
SMALLINT owReadByte(int portnum)
{
   return owTouchByte(portnum,0xFF);
}

//--------------------------------------------------------------------------
// Set the 1-Wire Net communication speed.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number is provided to
//                indicate the symbolic port number.
// 'new_speed'  - new speed defined as
//                MODE_NORMAL     0x00
//                MODE_OVERDRIVE  0x01
//
// Returns:  current 1-Wire Net speed
//
SMALLINT owSpeed(int portnum, SMALLINT new_speed)
{
   int select;
   select = 0x1 << portnum;
   // if overdrive is implemented use it
   if (sockit_owm.ovd_e) {
      if (new_speed == MODE_OVERDRIVE)  sockit_owm.ovd |=  select;
      if (new_speed == MODE_NORMAL   )  sockit_owm.ovd &= ~select;
   }
   // return the current port state
   return (sockit_owm.ovd & select) ? MODE_OVERDRIVE : MODE_NORMAL;
}

//--------------------------------------------------------------------------
// Set the 1-Wire Net line level.  The values for NewLevel are
// as follows:
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number is provided to
//                indicate the symbolic port number.
// 'new_level'  - new level defined as
//                MODE_NORMAL     0x00
//                MODE_STRONG5    0x02
//                MODE_PROGRAM    0x04
//                MODE_BREAK      0x08
//
// Returns:  current 1-Wire Net level
//
SMALLINT owLevel(int portnum, SMALLINT new_level)
{
   if (new_level == MODE_STRONG5) {
      // set the power bit
      sockit_owm.pwr |=  (1 << portnum);
      IOWR_SOCKIT_OWM_CTL (sockit_owm.base, (sockit_owm.pwr << SOCKIT_OWM_CTL_POWER_OFST) | SOCKIT_OWM_CTL_PWR_MSK);
   }
   if (new_level == MODE_NORMAL) {
      // clear the power bit
      sockit_owm.pwr &= ~(1 << portnum);
      IOWR_SOCKIT_OWM_CTL (sockit_owm.base, (sockit_owm.pwr << SOCKIT_OWM_CTL_POWER_OFST));
   }
   // return the current port state
   return ((sockit_owm.pwr >> portnum) & 0x1) ? MODE_STRONG5 : MODE_NORMAL;
}

//--------------------------------------------------------------------------
// This procedure creates a fixed 480 microseconds 12 volt pulse
// on the 1-Wire Net for programming EPROM iButtons.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number is provided to
//                indicate the symbolic port number.
//
// Returns:  TRUE  successful
//           FALSE program voltage not available
//
SMALLINT owProgramPulse(int portnum)
{
   return owHasProgramPulse(portnum);
}

//--------------------------------------------------------------------------
//  Description:
//     Delay for at least 'len' ms
//
void msDelay(int len)
{
#if SOCKIT_OWM_HW_DLY
   int i;

   // compute the number delay cycles depending on delay time
   len = (len * sockit_owm.f_dly) >> 16;

   // lock transfer
   ALT_SEM_PEND (sockit_owm.cyc, 0);

   for (i=0; i<len; i++) {
      // create a 960us pause
      IOWR_SOCKIT_OWM_CTL (sockit_owm.base, ( sockit_owm.pwr        << SOCKIT_OWM_CTL_POWER_OFST    )
                                          | ( sockit_owm.ien         ? SOCKIT_OWM_CTL_IEN_MSK : 0x00)
                                          | ((sockit_owm.pwr & 0x1)  ? SOCKIT_OWM_CTL_PWR_MSK : 0x00)
                                          | (                          SOCKIT_OWM_CTL_CYC_MSK       )
                                          | (                          SOCKIT_OWM_CTL_DLY_MSK       ));

     // wait for irq to set the transfer end flag
     ALT_FLAG_PEND (sockit_owm.irq, 0x1, OS_FLAG_WAIT_SET_ANY + OS_FLAG_CONSUME, 0);
     // wait for STX (end of transfer cycle)
     while (IORD_SOCKIT_OWM_CTL (sockit_owm.base) & SOCKIT_OWM_CTL_CYC_MSK);

     // release transfer lock
     ALT_SEM_POST (sockit_owm.cyc);
   }
#else
#ifdef UCOS_II
   // uCOS-II timed delay
   OSTimeDlyHMSM(0,0,0,len);
#else
   // Altera HAL us delay
   usleep (1000*len);
#endif
#endif
}

//--------------------------------------------------------------------------
// Get the current millisecond tick count.  Does not have to represent
// an actual time, it just needs to be an incrementing timer.
//
long msGettick(void)
{
#ifdef UCOS_II
   // uCOS-II tick counter
	OSTimeGet();
#else
   // TODO add platform specific code here
   return 0;
#endif
}

//--------------------------------------------------------------------------
// Send 8 bits of communication to the 1-Wire Net and verify that the
// 8 bits read from the 1-Wire Net is the same (write operation).
// The parameter 'sendbyte' least significant 8 bits are used.  After the
// 8 bits are sent change the level of the 1-Wire net.
//
// 'portnum'  - number 0 to MAX_PORTNUM-1.  This number was provided to
//              OpenCOM to indicate the port number.
// 'sendbyte' - 8 bits to send (least significant byte)
//
// Returns:  TRUE: bytes written and echo was the same
//           FALSE: echo was not the same
//
SMALLINT owWriteBytePower(int portnum, SMALLINT sendbyte)
{
   if (!owHasPowerDelivery(portnum))
      return FALSE;

   if(owTouchByte(portnum,sendbyte) != sendbyte)
      return FALSE;

   if(owLevel(portnum,MODE_STRONG5) != MODE_STRONG5)
      return FALSE;

   return TRUE;
}

//--------------------------------------------------------------------------
// Send 1 bit of communication to the 1-Wire Net and verify that the
// response matches the 'applyPowerResponse' bit and apply power delivery
// to the 1-Wire net.  Note that some implementations may apply the power
// first and then turn it off if the response is incorrect.
//
// 'portnum'  - number 0 to MAX_PORTNUM-1.  This number was provided to
//              OpenCOM to indicate the port number.
// 'applyPowerResponse' - 1 bit response to check, if correct then start
//                        power delivery
//
// Returns:  TRUE: bit written and response correct, strong pullup now on
//           FALSE: response incorrect
//
SMALLINT owReadBitPower(int portnum, SMALLINT applyPowerResponse)
{
   if (!owHasPowerDelivery(portnum))
      return FALSE;

   if(owTouchBit(portnum,0x01) != applyPowerResponse)
      return FALSE;

   if(owLevel(portnum,MODE_STRONG5) != MODE_STRONG5)
      return FALSE;

   return TRUE;
}

//--------------------------------------------------------------------------
// Read 8 bits of communication to the 1-Wire Net and then turn on
// power delivery.
//
// 'portnum'  - number 0 to MAX_PORTNUM-1.  This number was provided to
//              OpenCOM to indicate the port number.
//
// Returns:  byte read
//           FALSE: power delivery failed
//
SMALLINT owReadBytePower(int portnum)
{
   SMALLINT getbyte;

   if (!owHasPowerDelivery(portnum))
      return FALSE;

   getbyte = owTouchByte(portnum,0xFF);

   if (owLevel(portnum,MODE_STRONG5) != MODE_STRONG5)
      return FALSE;

   return getbyte;
}

//--------------------------------------------------------------------------
// This procedure indicates whether the adapter can deliver power.
//
// 'portnum'  - number 0 to MAX_PORTNUM-1.  This number was provided to
//              OpenCOM to indicate the port number.
//
// Returns:  TRUE  if adapter is capable of delivering power.
//
SMALLINT owHasPowerDelivery(int portnum)
{
   return TRUE;
}

//--------------------------------------------------------------------------
// This procedure indicates whether the adapter can deliver power.
//
// 'portnum'  - number 0 to MAX_PORTNUM-1.  This number was provided to
//              OpenCOM to indicate the port number.
//
// Returns:  TRUE  if adapter is capable of over drive.
//
SMALLINT owHasOverDrive(int portnum)
{
   return sockit_owm.ovd_e;
}

//--------------------------------------------------------------------------
// This procedure creates a fixed 480 microseconds 12 volt pulse
// on the 1-Wire Net for programming EPROM iButtons.
//
// 'portnum'  - number 0 to MAX_PORTNUM-1.  This number was provided to
//              OpenCOM to indicate the port number.
//
// Returns:  TRUE  program voltage available
//           FALSE program voltage not available
SMALLINT owHasProgramPulse(int portnum)
{
   return FALSE;
}
