//---------------------------------------------------------------------------
// Copyright (C) 1999 Dallas Semiconductor Corporation, All Rights Reserved.
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
//  owTran.C - Transport functions for 1-Wire devices.
//
//  Version: 2.01
//
//  History: 1.03 -> 2.00  Changed 'MLan' to 'ow'. Added support for
//                         multiple ports.
//           2.00 -> 2.01  Added support for owError library
//

#include "ownet.h"

//--------------------------------------------------------------------------
// The 'owBlock' transfers a block of data to and from the
// 1-Wire Net with an optional reset at the begining of communication.
// The result is returned in the same buffer.
//
// 'do_reset' - cause a owTouchReset to occure at the begining of
//              communication TRUE(1) or not FALSE(0)
// 'tran_buf' - pointer to a block of unsigned
//              chars of length 'TranferLength' that will be sent
//              to the 1-Wire Net
// 'tran_len' - length in bytes to transfer
// Supported devices: all
//
// Returns:   TRUE (1) : The optional reset returned a valid
//                       presence (do_reset == TRUE) or there
//                       was no reset required.
//            FALSE (0): The reset did not return a valid prsence
//                       (do_reset == TRUE).
//
//  The maximum tran_len is 160
//
SMALLINT owBlock(int portnum, SMALLINT do_reset, uchar *tran_buf, SMALLINT tran_len)
{
   uchar i;

   // check for a block too big
   if (tran_len > 160)
   {
      OWERROR(OWERROR_BLOCK_TOO_BIG);
      return FALSE;
   }

   // check if need to do a owTouchReset first
   if (do_reset)
   {
      if (!owTouchReset(portnum))
      {
         OWERROR(OWERROR_NO_DEVICES_ON_NET);
         return FALSE;
      }
   }

   // send and receive the buffer
   for (i = 0; i < tran_len; i++)
      tran_buf[i] = (uchar)owTouchByte(portnum,tran_buf[i]);

   return TRUE;
}

//--------------------------------------------------------------------------
// Write a byte to an EPROM 1-Wire device.
//
// Supported devices: crc_type=0(CRC8)
//                        DS1982
//                    crc_type=1(CRC16)
//                        DS1985, DS1986, DS2407
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number is provided to
//                indicate the symbolic port number.
// 'write_byte' - byte to program
// 'addr'       - address of byte to program
// 'write_cmd'  - command used to write (0x0F reg mem, 0x55 status)
// 'crc_type'   - CRC used (0 CRC8, 1 CRC16)
// 'do_access'  - Flag to access device for each byte
//                (0 skip access, 1 do the access)
//                WARNING, only use do_access=0 if programing the NEXT
//                byte immediatly after the previous byte.
//
// Returns: >=0   success, this is the resulting byte from the program
//                effort
//          -1    error, device not connected or program pulse voltage
//                not available
//
SMALLINT owProgramByte(int portnum, SMALLINT write_byte, int addr, SMALLINT write_cmd,
                       SMALLINT crc_type, SMALLINT do_access)
{
   ushort lastcrc16;
   uchar lastcrc8;

   // optionally access the device
   if (do_access)
   {
      if (!owAccess(portnum))
      {
         OWERROR(OWERROR_ACCESS_FAILED);
         return -1;
      }

      // send the write command
      if (!owWriteByte(portnum,write_cmd))
      {
         OWERROR(OWERROR_WRITE_BYTE_FAILED);
         return -1;
      }

      // send the address
      if (!owWriteByte(portnum,addr & 0xFF) || !owWriteByte(portnum,addr >> 8))
      {
         OWERROR(OWERROR_WRITE_BYTE_FAILED);
         return -1;
      }
   }

   // send the data to write
   if (!owWriteByte(portnum,write_byte))
   {
      OWERROR(OWERROR_WRITE_BYTE_FAILED);
      return -1;
   }

   // read the CRC
   if (crc_type == 0)
   {
      // calculate CRC8
      if (do_access)
      {
         setcrc8(portnum,0);
         docrc8(portnum,(uchar)write_cmd);
         docrc8(portnum,(uchar)(addr & 0xFF));
         docrc8(portnum,(uchar)(addr >> 8));
      }
      else
         setcrc8(portnum,(uchar)(addr & 0xFF));

      docrc8(portnum,(uchar)write_byte);
      // read and calculate the read crc
      lastcrc8 = docrc8(portnum,(uchar)owReadByte(portnum));
      // crc should now be 0x00
      if (lastcrc8 != 0)
      {
         OWERROR(OWERROR_CRC_FAILED);
         return -1;
      }
   }
   else
   {
      // CRC16
      if (do_access)
      {
         setcrc16(portnum,0);
         docrc16(portnum,(ushort)write_cmd);
         docrc16(portnum,(ushort)(addr & 0xFF));
         docrc16(portnum,(ushort)(addr >> 8));
      }
      else
         setcrc16(portnum,(ushort)addr);
      docrc16(portnum,(ushort)write_byte);
      // read and calculate the read crc
      docrc16(portnum,(ushort)owReadByte(portnum));
      lastcrc16 = docrc16(portnum,(ushort)owReadByte(portnum));
      // crc should now be 0xB001
      if (lastcrc16 != 0xB001)
         return -1;
   }

   // send the program pulse
   if (!owProgramPulse(portnum))
   {
      OWERROR(OWERROR_PROGRAM_PULSE_FAILED);
      return -1;
   }

   // read back and return the resulting byte
   return owReadByte(portnum);
}


