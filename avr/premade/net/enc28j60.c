/*! \file enc28j60.c \brief Microchip ENC28J60 Ethernet Interface Driver. */
//*****************************************************************************
//
// File Name	: 'enc28j60.c'
// Title		: Microchip ENC28J60 Ethernet Interface Driver
// Author		: Pascal Stang (c)2005
// Created		: 9/22/2005
// Revised		: 9/22/2005
// Version		: 0.1
// Target MCU	: Atmel AVR series
// Editor Tabs	: 4
//
// Description	: This driver provides initialization and transmit/receive
//	functions for the Microchip ENC28J60 10Mb Ethernet Controller and PHY.
// This chip is novel in that it is a full MAC+PHY interface all in a 28-pin
// chip, using an SPI interface to the host processor.
//
//*****************************************************************************

#include "avr/io.h"

#include "global.h"
#include "timer.h"
#include "rprintf.h"

#include "enc28j60.h"
/*
#ifdef SPDR0
	#define SPDR	SPDR0
	#define SPCR	SPCR0
	#define SPSR	SPSR0

	#define SPIF	SPIF0
	#define MSTR	MSTR0
	#define CPOL	CPOL0

	#define DORD	DORD0
	#define SPR0	SPR00
	#define SPR1	SPR01
	#define SPI2X	SPI2X0
	#define SPE		SPE0
#endif
*/
// include configuration
#include "enc28j60conf.h"

u08 Enc28j60Bank;
u16 NextPacketPtr;

void nicInit(void)
{
	enc28j60Init();
}

void nicSend(unsigned int len, unsigned char* packet)
{
	enc28j60PacketSend(len, packet);
}

unsigned int nicPoll(unsigned int maxlen, unsigned char* packet)
{
	return enc28j60PacketReceive(maxlen, packet);
}

void nicGetMacAddress(u08* macaddr)
{
	// read MAC address registers
	// NOTE: MAC address in ENC28J60 is byte-backward
	*macaddr++ = enc28j60Read(MAADR5);
	*macaddr++ = enc28j60Read(MAADR4);
	*macaddr++ = enc28j60Read(MAADR3);
	*macaddr++ = enc28j60Read(MAADR2);
	*macaddr++ = enc28j60Read(MAADR1);
	*macaddr++ = enc28j60Read(MAADR0);
}

void nicSetMacAddress(u08* macaddr)
{
	// write MAC address
	// NOTE: MAC address in ENC28J60 is byte-backward
	enc28j60Write(MAADR5, *macaddr++);
	enc28j60Write(MAADR4, *macaddr++);
	enc28j60Write(MAADR3, *macaddr++);
	enc28j60Write(MAADR2, *macaddr++);
	enc28j60Write(MAADR1, *macaddr++);
	enc28j60Write(MAADR0, *macaddr++);
}

void nicRegDump(void)
{
	enc28j60RegDump();
}

/*
void ax88796SetupPorts(void)
{
#if NIC_CONNECTION == MEMORY_MAPPED
	// enable external SRAM interface - no wait states
	sbi(MCUCR, SRE);
//	sbi(MCUCR, SRW10);
//	sbi(XMCRA, SRW00);
//	sbi(XMCRA, SRW01);
//	sbi(XMCRA, SRW11);
#else
	// set address port to output
	AX88796_ADDRESS_DDR = AX88796_ADDRESS_MASK;
    
	// set data port to input with pull-ups
	AX88796_DATA_DDR = 0x00;
	AX88796_DATA_PORT = 0xFF;

	// initialize the control port read and write pins to de-asserted
	sbi( AX88796_CONTROL_PORT, AX88796_CONTROL_READPIN );
	sbi( AX88796_CONTROL_PORT, AX88796_CONTROL_WRITEPIN );
	// set the read and write pins to output
	sbi( AX88796_CONTROL_DDR, AX88796_CONTROL_READPIN );
	sbi( AX88796_CONTROL_DDR, AX88796_CONTROL_WRITEPIN );
#endif
	// set reset pin to output
	sbi( AX88796_RESET_DDR, AX88796_RESET_PIN );
}
*/

u08 enc28j60ReadOp(u08 op, u08 address)
{
	u08 data;
   
	// assert CS
	ENC28J60_CONTROL_PORT &= ~(1<<ENC28J60_CONTROL_CS);
	
	// issue read command
	SPDR = op | (address & ADDR_MASK);
	while(!(SPSR & (1<<SPIF)));
	// read data
	SPDR = 0x00;
	while(!(SPSR & (1<<SPIF)));
	// do dummy read if needed
	if(address & 0x80)
	{
		SPDR = 0x00;
		while(!(inb(SPSR) & (1<<SPIF)));
	}
	data = SPDR;
	
	// release CS
	ENC28J60_CONTROL_PORT |= (1<<ENC28J60_CONTROL_CS);

	return data;
}

void enc28j60WriteOp(u08 op, u08 address, u08 data)
{
	// assert CS
	ENC28J60_CONTROL_PORT &= ~(1<<ENC28J60_CONTROL_CS);

	// issue write command
	SPDR = op | (address & ADDR_MASK);
	while(!(SPSR & (1<<SPIF)));
	// write data
	SPDR = data;
	while(!(SPSR & (1<<SPIF)));

	// release CS
	ENC28J60_CONTROL_PORT |= (1<<ENC28J60_CONTROL_CS);
}

void enc28j60ReadBuffer(u16 len, u08* data)
{
	// assert CS
	ENC28J60_CONTROL_PORT &= ~(1<<ENC28J60_CONTROL_CS);
	
	// issue read command
	SPDR = ENC28J60_READ_BUF_MEM;
	while(!(SPSR & (1<<SPIF)));
	while(len--)
	{
		// read data
		SPDR = 0x00;
		while(!(SPSR & (1<<SPIF)));
		*data++ = SPDR;
	}	
	// release CS
	ENC28J60_CONTROL_PORT |= (1<<ENC28J60_CONTROL_CS);
}

void enc28j60WriteBuffer(u16 len, u08* data)
{
	// assert CS
	ENC28J60_CONTROL_PORT &= ~(1<<ENC28J60_CONTROL_CS);
	
	// issue write command
	SPDR = ENC28J60_WRITE_BUF_MEM;
	while(!(SPSR & (1<<SPIF)));
	while(len--)
	{
		// write data
		SPDR = *data++;
		while(!(SPSR & (1<<SPIF)));
	}	
	// release CS
	ENC28J60_CONTROL_PORT |= (1<<ENC28J60_CONTROL_CS);
}

void enc28j60SetBank(u08 address)
{
	// set the bank (if needed)
	if((address & BANK_MASK) != Enc28j60Bank)
	{
		// set the bank
		enc28j60WriteOp(ENC28J60_BIT_FIELD_CLR, ECON1, (ECON1_BSEL1|ECON1_BSEL0));
		enc28j60WriteOp(ENC28J60_BIT_FIELD_SET, ECON1, (address & BANK_MASK)>>5);
		Enc28j60Bank = (address & BANK_MASK);
	}
}

u08 enc28j60Read(u08 address)
{
	// set the bank
	enc28j60SetBank(address);
	// do the read
	return enc28j60ReadOp(ENC28J60_READ_CTRL_REG, address);
}

void enc28j60Write(u08 address, u08 data)
{
	// set the bank
	enc28j60SetBank(address);
	// do the write
	enc28j60WriteOp(ENC28J60_WRITE_CTRL_REG, address, data);
}

u16 enc28j60PhyRead(u08 address)
{
	u16 data;

	// Set the right address and start the register read operation
	enc28j60Write(MIREGADR, address);
	enc28j60Write(MICMD, MICMD_MIIRD);

	// wait until the PHY read completes
	while(enc28j60Read(MISTAT) & MISTAT_BUSY);

	// quit reading
	enc28j60Write(MICMD, 0x00);
	
	// get data value
	data  = enc28j60Read(MIRDL);
	data |= enc28j60Read(MIRDH);
	// return the data
	return data;
}

void enc28j60PhyWrite(u08 address, u16 data)
{
	// set the PHY register address
	enc28j60Write(MIREGADR, address);
	
	// write the PHY data
	enc28j60Write(MIWRL, data);	
	enc28j60Write(MIWRH, data>>8);

	// wait until the PHY write completes
	while(enc28j60Read(MISTAT) & MISTAT_BUSY);
}

void enc28j60Init(void)
{
	// initialize I/O
	sbi(ENC28J60_CONTROL_DDR, ENC28J60_CONTROL_CS);
	sbi(ENC28J60_CONTROL_PORT, ENC28J60_CONTROL_CS);

	// setup SPI I/O pins
	// SCK should be low!
	cbi(ENC28J60_SPI_PORT, ENC28J60_SPI_SCK);	// set SCK hi
	sbi(ENC28J60_SPI_DDR, ENC28J60_SPI_SCK);	// set SCK as output
	cbi(ENC28J60_SPI_DDR, ENC28J60_SPI_MISO);	// set MISO as input
	sbi(ENC28J60_SPI_DDR, ENC28J60_SPI_MOSI);	// set MOSI as output
	sbi(ENC28J60_SPI_DDR, ENC28J60_SPI_SS);		// SS must be output for Master mode to work
	// initialize SPI interface
	// master mode
	sbi(SPCR, MSTR);
	// select clock phase positive-going in middle of data
	cbi(SPCR, CPOL);
	// select clock phase
	cbi(SPCR, CPHA);
	// Data order MSB first
	cbi(SPCR,DORD);
	// switch to f/4 2X = f/2 bitrate
	cbi(SPCR, SPR0);
	sbi(SPCR, SPR1);
	// No dual datarate
	cbi(SPSR, SPI2X);
	// enable SPI
	sbi(SPCR, SPE);

	// perform system reset
	enc28j60WriteOp(ENC28J60_SOFT_RESET, 0, ENC28J60_SOFT_RESET);
	// check CLKRDY bit to see if reset is complete
	delay_us(50);
	while(!(enc28j60Read(ESTAT) & ESTAT_CLKRDY));

	// do bank 0 stuff
	// initialize receive buffer
	// 16-bit transfers, must write low byte first
	// set receive buffer start address
	NextPacketPtr = RXSTART_INIT;
	enc28j60Write(ERXSTL, RXSTART_INIT&0xFF);
	enc28j60Write(ERXSTH, RXSTART_INIT>>8);
	// set receive pointer address
	enc28j60Write(ERXRDPTL, RXSTART_INIT&0xFF);
	enc28j60Write(ERXRDPTH, RXSTART_INIT>>8);
	// set receive buffer end
	// ERXND defaults to 0x1FFF (end of ram)
	enc28j60Write(ERXNDL, RXSTOP_INIT&0xFF);
	enc28j60Write(ERXNDH, RXSTOP_INIT>>8);
	// set transmit buffer start
	// ETXST defaults to 0x0000 (beginnging of ram)
	enc28j60Write(ETXSTL, TXSTART_INIT&0xFF);
	enc28j60Write(ETXSTH, TXSTART_INIT>>8);

	// do bank 2 stuff
	// enable MAC receive
	enc28j60Write(MACON1, MACON1_MARXEN|MACON1_TXPAUS|MACON1_RXPAUS);
	// bring MAC out of reset
	enc28j60Write(MACON2, 0x00);
	// enable automatic padding and CRC operations
	enc28j60WriteOp(ENC28J60_BIT_FIELD_SET, MACON3, MACON3_PADCFG0|MACON3_TXCRCEN|MACON3_FRMLNEN);
//	enc28j60Write(MACON3, MACON3_PADCFG0|MACON3_TXCRCEN|MACON3_FRMLNEN);
	// set inter-frame gap (non-back-to-back)
	enc28j60Write(MAIPGL, 0x12);
	enc28j60Write(MAIPGH, 0x0C);
	// set inter-frame gap (back-to-back)
	enc28j60Write(MABBIPG, 0x12);
	// Set the maximum packet size which the controller will accept
	enc28j60Write(MAMXFLL, MAX_FRAMELEN&0xFF);	
	enc28j60Write(MAMXFLH, MAX_FRAMELEN>>8);

	// do bank 3 stuff
	// write MAC address
	// NOTE: MAC address in ENC28J60 is byte-backward
	enc28j60Write(MAADR5, ENC28J60_MAC0);
	enc28j60Write(MAADR4, ENC28J60_MAC1);
	enc28j60Write(MAADR3, ENC28J60_MAC2);
	enc28j60Write(MAADR2, ENC28J60_MAC3);
	enc28j60Write(MAADR1, ENC28J60_MAC4);
	enc28j60Write(MAADR0, ENC28J60_MAC5);

	// no loopback of transmitted frames
	enc28j60PhyWrite(PHCON2, PHCON2_HDLDIS);

	// switch to bank 0
	enc28j60SetBank(ECON1);
	// enable interrutps
	enc28j60WriteOp(ENC28J60_BIT_FIELD_SET, EIE, EIE_INTIE|EIE_PKTIE);
	// enable packet reception
	enc28j60WriteOp(ENC28J60_BIT_FIELD_SET, ECON1, ECON1_RXEN);
/*
	enc28j60PhyWrite(PHLCON, 0x0AA2);

	// setup duplex ----------------------

	// Disable receive logic and abort any packets currently being transmitted
	enc28j60WriteOp(ENC28J60_BIT_FIELD_CLR, ECON1, ECON1_TXRTS|ECON1_RXEN);
	
	{
		u16 temp;
		// Set the PHY to the proper duplex mode
		temp = enc28j60PhyRead(PHCON1);
		temp &= ~PHCON1_PDPXMD;
		enc28j60PhyWrite(PHCON1, temp);
		// Set the MAC to the proper duplex mode
		temp = enc28j60Read(MACON3);
		temp &= ~MACON3_FULDPX;
		enc28j60Write(MACON3, temp);
	}

	// Set the back-to-back inter-packet gap time to IEEE specified 
	// requirements.  The meaning of the MABBIPG value changes with the duplex
	// state, so it must be updated in this function.
	// In full duplex, 0x15 represents 9.6us; 0x12 is 9.6us in half duplex
	//enc28j60Write(MABBIPG, DuplexState ? 0x15 : 0x12);	
	
	// Reenable receive logic
	enc28j60WriteOp(ENC28J60_BIT_FIELD_SET, ECON1, ECON1_RXEN);

	// setup duplex ----------------------
*/
}

void enc28j60PacketSend(unsigned int len, unsigned char* packet)
{
	// Set the write pointer to start of transmit buffer area
	enc28j60Write(EWRPTL, TXSTART_INIT);
	enc28j60Write(EWRPTH, TXSTART_INIT>>8);
	// Set the TXND pointer to correspond to the packet size given
	enc28j60Write(ETXNDL, (TXSTART_INIT+len));
	enc28j60Write(ETXNDH, (TXSTART_INIT+len)>>8);

	// write per-packet control byte
	enc28j60WriteOp(ENC28J60_WRITE_BUF_MEM, 0, 0x00);

	// copy the packet into the transmit buffer
	enc28j60WriteBuffer(len, packet);
	
	// send the contents of the transmit buffer onto the network
	enc28j60WriteOp(ENC28J60_BIT_FIELD_SET, ECON1, ECON1_TXRTS);
}

unsigned int enc28j60PacketReceive(unsigned int maxlen, unsigned char* packet)
{
	u16 rxstat;
	u16 len;

	// check if a packet has been received and buffered
//	if( !(enc28j60Read(EIR) & EIR_PKTIF) )
	if( !enc28j60Read(EPKTCNT) )
		return 0;
	
	// Make absolutely certain that any previous packet was discarded	
	//if( WasDiscarded == FALSE)
	//	MACDiscardRx();

	// Set the read pointer to the start of the received packet
	enc28j60Write(ERDPTL, (NextPacketPtr));
	enc28j60Write(ERDPTH, (NextPacketPtr)>>8);
	// read the next packet pointer
	NextPacketPtr  = enc28j60ReadOp(ENC28J60_READ_BUF_MEM, 0);
	NextPacketPtr |= enc28j60ReadOp(ENC28J60_READ_BUF_MEM, 0)<<8;
	// read the packet length
	len  = enc28j60ReadOp(ENC28J60_READ_BUF_MEM, 0);
	len |= enc28j60ReadOp(ENC28J60_READ_BUF_MEM, 0)<<8;
	// read the receive status
	rxstat  = enc28j60ReadOp(ENC28J60_READ_BUF_MEM, 0);
	rxstat |= enc28j60ReadOp(ENC28J60_READ_BUF_MEM, 0)<<8;

	// limit retrieve length
	// (we reduce the MAC-reported length by 4 to remove the CRC)
	len = MIN(len, maxlen);

	// copy the packet from the receive buffer
	enc28j60ReadBuffer(len, packet);

	// Move the RX read pointer to the start of the next received packet
	// This frees the memory we just read out
	enc28j60Write(ERXRDPTL, (NextPacketPtr));
	enc28j60Write(ERXRDPTH, (NextPacketPtr)>>8);

	// decrement the packet counter indicate we are done with this packet
	enc28j60WriteOp(ENC28J60_BIT_FIELD_SET, ECON2, ECON2_PKTDEC);

	return len;
}

void enc28j60ReceiveOverflowRecover(void)
{
	// receive buffer overflow handling procedure

	// recovery completed
}

void enc28j60RegDump(void)
{
//	unsigned char macaddr[6];
//	result = ax88796Read(TR);
	
//	rprintf("Media State: ");
//	if(!(result & AUTOD))
//		rprintf("Autonegotiation\r\n");
//	else if(result & RST_B)
//		rprintf("PHY in Reset   \r\n");
//	else if(!(result & RST_10B))
//		rprintf("10BASE-T       \r\n");
//	else if(!(result & RST_TXB))
//		rprintf("100BASE-T      \r\n");
				
	rprintf("RevID: 0x%x\r\n", enc28j60Read(EREVID));

	rprintfProgStrM("Cntrl: ECON1 ECON2 ESTAT  EIR  EIE\r\n");
	rprintfProgStrM("         ");
	rprintfu08(enc28j60Read(ECON1));
	rprintfProgStrM("    ");
	rprintfu08(enc28j60Read(ECON2));
	rprintfProgStrM("    ");
	rprintfu08(enc28j60Read(ESTAT));
	rprintfProgStrM("    ");
	rprintfu08(enc28j60Read(EIR));
	rprintfProgStrM("   ");
	rprintfu08(enc28j60Read(EIE));
	rprintfCRLF();

	rprintfProgStrM("MAC  : MACON1  MACON2  MACON3  MACON4  MAC-Address\r\n");
	rprintfProgStrM("        0x");
	rprintfu08(enc28j60Read(MACON1));
	rprintfProgStrM("    0x");
	rprintfu08(enc28j60Read(MACON2));
	rprintfProgStrM("    0x");
	rprintfu08(enc28j60Read(MACON3));
	rprintfProgStrM("    0x");
	rprintfu08(enc28j60Read(MACON4));
	rprintfProgStrM("   ");
	rprintfu08(enc28j60Read(MAADR5));
	rprintfu08(enc28j60Read(MAADR4));
	rprintfu08(enc28j60Read(MAADR3));
	rprintfu08(enc28j60Read(MAADR2));
	rprintfu08(enc28j60Read(MAADR1));
	rprintfu08(enc28j60Read(MAADR0));
	rprintfCRLF();

	rprintfProgStrM("Rx   : ERXST  ERXND  ERXWRPT ERXRDPT ERXFCON EPKTCNT MAMXFL\r\n");
	rprintfProgStrM("       0x");
	rprintfu08(enc28j60Read(ERXSTH));
	rprintfu08(enc28j60Read(ERXSTL));
	rprintfProgStrM(" 0x");
	rprintfu08(enc28j60Read(ERXNDH));
	rprintfu08(enc28j60Read(ERXNDL));
	rprintfProgStrM("  0x");
	rprintfu08(enc28j60Read(ERXWRPTH));
	rprintfu08(enc28j60Read(ERXWRPTL));
	rprintfProgStrM("  0x");
	rprintfu08(enc28j60Read(ERXRDPTH));
	rprintfu08(enc28j60Read(ERXRDPTL));
	rprintfProgStrM("   0x");
	rprintfu08(enc28j60Read(ERXFCON));
	rprintfProgStrM("    0x");
	rprintfu08(enc28j60Read(EPKTCNT));
	rprintfProgStrM("  0x");
	rprintfu08(enc28j60Read(MAMXFLH));
	rprintfu08(enc28j60Read(MAMXFLL));
	rprintfCRLF();

	rprintfProgStrM("Tx   : ETXST  ETXND  MACLCON1 MACLCON2 MAPHSUP\r\n");
	rprintfProgStrM("       0x");
	rprintfu08(enc28j60Read(ETXSTH));
	rprintfu08(enc28j60Read(ETXSTL));
	rprintfProgStrM(" 0x");
	rprintfu08(enc28j60Read(ETXNDH));
	rprintfu08(enc28j60Read(ETXNDL));
	rprintfProgStrM("   0x");
	rprintfu08(enc28j60Read(MACLCON1));
	rprintfProgStrM("     0x");
	rprintfu08(enc28j60Read(MACLCON2));
	rprintfProgStrM("     0x");
	rprintfu08(enc28j60Read(MAPHSUP));
	rprintfCRLF();

	rprintfProgStrM("EREVID\r\n");
	rprintfProgStrM("       0x");
	rprintfu08(enc28j60Read(EREVID));
	
	delay_ms(25);
}



