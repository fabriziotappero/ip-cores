//********************************************************************************************
//
// YagnaInnWebServer firmware 
//
// Author(s) : Dinesh Annayya, dinesha@opencores.org   
// Website   : http://www.yagnainn.com/
// MCU       : Open Core 8051 @ 50Mhz
// Version   : 1.0
//********************************************************************************************
//
// File : ethDriver.c Ethernet Driver for Yagna Innovation -WebBrowser development board.
//
//********************************************************************************************
//
// Copyright (C) 2007
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
// This program is distributed in the hope that it will be useful, but
//
// WITHOUT ANY WARRANTY;
//
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin St, Fifth Floor, Boston, MA 02110, USA
//
// http://www.gnu.de/gpl-ger.html
//
//********************************************************************************************
#include "includes.h"
//
//#define F_CPU 8000000UL  // 8 MHz

//struct enc28j60_flag
//{
//	unsigned rx_buffer_is_free:1;
//	unsigned unuse:7;
//}enc28j60_flag;
static BYTE Enc28j60Bank;
static WORD_BYTES next_packet_ptr;
extern unsigned int iRxFrmCnt ;
extern unsigned int iTxFrmCnt ;
extern unsigned int iRxDescPtr;
extern unsigned int iTxDescPtr;

//*******************************************************************************************
//
// Function : icmp_send_request
// Description : Send ARP request packet to destination.
//
//*******************************************************************************************
BYTE enc28j60ReadOp(BYTE op, BYTE address)
{
	return(0);
}
//*******************************************************************************************
//
// Function : icmp_send_request
// Description : Send ARP request packet to destination.
//
//*******************************************************************************************
void enc28j60WriteOp(BYTE op, BYTE address, BYTE datap)
{
}
//*******************************************************************************************
//
// Function : icmp_send_request
// Description : Send ARP request packet to destination.
//
//*******************************************************************************************
void enc28j60SetBank(BYTE address)
{
}
//*******************************************************************************************
//
// Function : icmp_send_request
// Description : Send ARP request packet to destination.
//
//*******************************************************************************************
BYTE enc28j60Read(BYTE address)
{
	// select bank to read
	enc28j60SetBank(address);
	
	// do the read
	return enc28j60ReadOp(ENC28J60_READ_CTRL_REG, address);
}
//*******************************************************************************************
//
// Function : icmp_send_request
// Description : Send ARP request packet to destination.
//
//*******************************************************************************************
void enc28j60Write(BYTE address, BYTE datap)
{
}
//*******************************************************************************************
//
// Function : icmp_send_request
// Description : Send ARP request packet to destination.
//
//*******************************************************************************************
WORD enc28j60_read_phyreg(BYTE address)
{
	return 0;
}
//*******************************************************************************************
//
// Function : icmp_send_request
// Description : Send ARP request packet to destination.
//
//*******************************************************************************************
void enc28j60PhyWrite(BYTE address, WORD datap)
{
}
//*******************************************************************************************
//
// Function : icmp_send_request
// Description : Send ARP request packet to destination.
//
//*******************************************************************************************
/*
void enc28j60_init( BYTE *avr_mac)
{
}
*/
void enc28j60_init( BYTE *avr_mac)
{
}
//*******************************************************************************************
//
// Function : enc28j60getrev
// Description : read the revision of the chip.
//
//*******************************************************************************************
BYTE enc28j60getrev(void)
{
	return(0);
}
//*******************************************************************************************
//
// Function : enc28j60_packet_send
// Description : Send packet to network.
//
//*******************************************************************************************
void enc28j60_packet_send ( BYTE **buffer, WORD length )
{
   XDWORD *pTxDesPtr;
   XDWORD iWrData;
   XWORD iTxNextPtr;
    pTxDesPtr = (XDWORD *) (0x7040 | iTxDescPtr);
    //*pTxDesPtr = (length & 0xFFF) ;
    iWrData = (XDWORD) *buffer;
    iWrData = iWrData >> 2;  // Aligned 32bit Addressing
    iWrData = iWrData << 12; // Move the Address
    iWrData |= (length & 0xFFF);
    *pTxDesPtr = iWrData;
//    *pTxDesPtr |= ((buffer << 12) & 0x3FFF000);
    iTxDescPtr = (iTxDescPtr+4) & 0x3F;
    iTxFrmCnt  = iRxFrmCnt+1;

    iTxNextPtr = (WORD) *buffer;
    iTxNextPtr = iTxNextPtr+length; // 32 Bit Aligned
    iTxNextPtr &= 0x3FFC; // 4K Aligned, Last 2 bit Zero, 32 Bit Aligned
    *buffer = (BYTE *)iTxNextPtr;
}
//*******************************************************************************************
//
// Function : enc28j60_mac_is_linked
// Description : return MAC link status.

WORD enc28j60_packet_receive ( BYTE **rxtx_buffer, WORD max_length )
{
    WORD_BYTES iRxFrmStatus, data_length;
   __xdata __at (0xA030) unsigned int iMacRxFrmCnt;
   __xdata unsigned long *pRxDesPtr;

   data_length.word = 0; // init

    // check if a packet has been received and buffered
    if((iMacRxFrmCnt & 0xF) != 0) { // Check the Rx Q Counter
       pRxDesPtr = (__xdata unsigned long *) (0x7000 | iRxDescPtr);
       data_length.word = *pRxDesPtr & 0xFFF; // Last 12 bit indicate the Length of the Packet
       *rxtx_buffer = (BYTE*) (((*pRxDesPtr >> 12) & 0x3FFF) << 2) ; // 32 bit Aligned Address
       iRxFrmStatus.word= *pRxDesPtr >> 26; // Upper 6 Bit Inidcate the Rx Status
       iRxDescPtr = (iRxDescPtr+4) & 0x3F;
       iRxFrmCnt  = iRxFrmCnt+1;

    }
    if ( data_length.word > (max_length-1) )
    {
      data_length.word= max_length-1;
    }
    return( data_length.word );
}

