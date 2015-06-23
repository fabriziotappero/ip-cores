/*********************************************
 * vim:sw=8:ts=8:si:et
 * To use the above modeline in vim you must have "set modeline" in your .vimrc
 * Author: Guido Socher 
 * Copyright: GPL V2
 *
 * Based on the enc28j60.c file from the AVRlib library by Pascal Stang.
 * For AVRlib See http://www.procyonengineering.com/
 * Used with explicit permission of Pascal Stang.
 *
 * Title: Microchip ENC28J60 Ethernet Interface Driver
 * Chip type           : ATMEGA88 with ENC28J60
 *********************************************/
#include <avr/io.h>
//#include "avr_compat.h"
#include "enc28j60.h"
#include "enc28j60conf.h"
#include <device.h>
//#include "nic.h"
#include "../global.h"
//#include "timeout.h"
#include <util/delay.h>

static uint8_t Enc28j60Bank;
static uint16_t NextPacketPtr;
// set CS to 0 = active
#define CSACTIVE ENC28J60_CONTROL_PORT&=~(1<<ENC28J60_CONTROL_CS)
// set CS to 1 = passive
#define CSPASSIVE ENC28J60_CONTROL_PORT|=(1<<ENC28J60_CONTROL_CS)
//
#define waitspi() while(!(SPSR&(1<<SPIF)))

//struct igordev_data idata;
int status;
/*
void nicInit(void)
{
	buf_init(&idata.readbuf);
	buf_init(&idata.writebuf);
	status = 0;
	enc28j60Init();
}
*/
void
nicDeinit(void)
{
	/* NOP */
}

/* Read function for our device framework */
/*int
nicRead(int numbytes)
{
	struct buf *buf;
	unsigned int len;
	char data;
	char err;
	int i;
*/
	/* XXX: Larger receive buffers. */
/*	buf = &idata.readbuf;
	for (i = 0; i < numbytes; i++) {
		len = nicPoll(1, &data);
		if (len == 0)
			break;
		err = buf_write(buf, data);
		if (err || buf->status & BUF_STATUS_FULL)
			break;
	}
	status = IDEV_STATUS_OK;
	return (0);
}
*/
/* Write function for our device framework. */
/*int
nicWrite(int numbytes)
{
	struct buf *buf;
	unsigned int len;
	char data;
	char err;
	int i;

	buf = &idata.writebuf;
*/	/* XXX: Larger send buffers. */
/*	for (i = 0; i < numbytes; i++) {
		err = buf_read(buf, &data);
		if (err || buf->status & BUF_STATUS_EMPTY)
			break;
		nicSend(1, &data);
	}
	status = IDEV_STATUS_OK;
}
*/
void nicSend(unsigned int len, uint8_t* packet)
{
	enc28j60PacketSend(len, packet);
}

unsigned int nicPoll(unsigned int maxlen, unsigned char* packet)
{
	return enc28j60PacketReceive(maxlen, packet);
}


uint8_t enc28j60ReadOp(uint8_t op, uint8_t address)
{
        CSACTIVE;
        // issue read command
        SPDR = op | (address & ADDR_MASK);
        waitspi();
        // read data
        SPDR = 0x00;
        waitspi();
        // do dummy read if needed (for mac and mii, see datasheet page 29)
        if(address & 0x80)
        {
                SPDR = 0x00;
                waitspi();
        }
        // release CS
        CSPASSIVE;
        return(SPDR);
}

void enc28j60WriteOp(uint8_t op, uint8_t address, uint8_t data)
{
        CSACTIVE;
        // issue write command
        SPDR = op | (address & ADDR_MASK);
        waitspi();
        // write data
        SPDR = data;
        waitspi();
        CSPASSIVE;
}

void enc28j60ReadBuffer(uint16_t len, uint8_t* data)
{
        CSACTIVE;
        // issue read command
        SPDR = ENC28J60_READ_BUF_MEM;
        waitspi();
        while(len)
        {
                len--;
                // read data
                SPDR = 0x00;
                waitspi();
                *data = SPDR;
                data++;
        }
        // This is nonsence : *data='\0';
        CSPASSIVE;
}

void enc28j60WriteBuffer(uint16_t len, uint8_t* data)
{
        CSACTIVE;
        // issue write command
        SPDR = ENC28J60_WRITE_BUF_MEM;
        waitspi();
        while(len)
        {
                len--;
                // write data
                SPDR = *data;
                data++;
                waitspi();
        }
        CSPASSIVE;
}

void enc28j60SetBank(uint8_t address)
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

uint8_t enc28j60Read(uint8_t address)
{
        // set the bank
        enc28j60SetBank(address);
        // do the read
        return enc28j60ReadOp(ENC28J60_READ_CTRL_REG, address);
}

void enc28j60Write(uint8_t address, uint8_t data)
{
        // set the bank
        enc28j60SetBank(address);
        // do the write
        enc28j60WriteOp(ENC28J60_WRITE_CTRL_REG, address, data);
}

void enc28j60PhyWrite(uint8_t address, uint16_t data)
{
        // set the PHY register address
        enc28j60Write(MIREGADR, address);
        // write the PHY data
        enc28j60Write(MIWRL, data);
        enc28j60Write(MIWRH, data>>8);
        // wait until the PHY write completes
        while(enc28j60Read(MISTAT) & MISTAT_BUSY){
                _delay_us(15);
        }
}


//Run configure_spi() to setup the SPI port before initializing the ethernet controller.
void enc28j60Init()
{

/*	// initialize I/O
	ENC28J60_CONTROL_DDR	|= (1<<ENC28J60_CONTROL_CS);
	ENC28J60_CONTROL_PORT	|= (1<<ENC28J60_CONTROL_CS);
	CSPASSIVE;

	// Disable powersaving
	PRR0 &= ~(1<<PRSPI);
	
	// setup SPI I/O pins
	// SCK should be low!
	ENC28J60_SPI_PORT	&= ~(1<<ENC28J60_SPI_SCK);
	ENC28J60_SPI_DDR	|=  (1<<ENC28J60_SPI_SCK);	// set SCK as output
	ENC28J60_SPI_DDR	&= ~(1<<ENC28J60_SPI_MISO);	// set MISO as input
	ENC28J60_SPI_DDR	|= ~(1<<ENC28J60_SPI_MOSI);	// set MOSI as output
	ENC28J60_SPI_PORT	&= ~(1<<ENC28J60_SPI_MOSI); // set MOSI low
	ENC28J60_SPI_DDR	|= ~(1<<ENC28J60_SPI_SS);	// SS must be output for Master mode to work
	// initialize SPI interface
	// master mode
	// select clock phase positive-going in middle of data
	// select clock phase
	// Data order MSB first
	// switch to f/4 2X = f/2 bitrate
	// No dual datarate

	SPCR = (1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<DORD)|(0<<SPR0)|(1<<SPR1)|(0<<SPI2X)|(1<<SPE);
*/
	// perform system reset
	enc28j60WriteOp(ENC28J60_SOFT_RESET, 0, ENC28J60_SOFT_RESET);
	_delay_ms(50);
	// check CLKRDY bit to see if reset is complete
        // The CLKRDY does not work. See Rev. B4 Silicon Errata point. Just wait.
	//while(!(enc28j60Read(ESTAT) & ESTAT_CLKRDY));
	// do bank 0 stuff
	// initialize receive buffer
	// 16-bit transfers, must write low byte first
	// set receive buffer start address
	NextPacketPtr = RXSTART_INIT;
        // Rx start
	enc28j60Write(ERXSTL, RXSTART_INIT&0xFF);
	enc28j60Write(ERXSTH, RXSTART_INIT>>8);
	// set receive pointer address
	enc28j60Write(ERXRDPTL, RXSTART_INIT&0xFF);
	enc28j60Write(ERXRDPTH, RXSTART_INIT>>8);
	// RX end
	enc28j60Write(ERXNDL, RXSTOP_INIT&0xFF);
	enc28j60Write(ERXNDH, RXSTOP_INIT>>8);
	// TX start
	enc28j60Write(ETXSTL, TXSTART_INIT&0xFF);
	enc28j60Write(ETXSTH, TXSTART_INIT>>8);
	// TX end
	enc28j60Write(ETXNDL, TXSTOP_INIT&0xFF);
	enc28j60Write(ETXNDH, TXSTOP_INIT>>8);
	// do bank 1 stuff, packet filter:
        // For broadcast packets we allow only ARP packtets
        // All other packets should be unicast only for our mac (MAADR)
        //
        // The pattern to match on is therefore
        // Type     ETH.DST
        // ARP      BROADCAST
        // 06 08 -- ff ff ff ff ff ff -> ip checksum for theses bytes=f7f9
        // in binary these poitions are:11 0000 0011 1111
        // This is hex 303F->EPMM0=0x3f,EPMM1=0x30
        enc28j60Write(ERXFCON, 0); //Disable packet filter
//	enc28j60Write(ERXFCON, ERXFCON_UCEN|ERXFCON_CRCEN|ERXFCON_PMEN);
//	enc28j60Write(EPMM0, 0x3f);
//	enc28j60Write(EPMM1, 0x30);
//	enc28j60Write(EPMCSL, 0xf9);
//	enc28j60Write(EPMCSH, 0xf7);
        //
        //
	// do bank 2 stuff
	// enable MAC receive
	enc28j60Write(MACON1, MACON1_MARXEN|MACON1_TXPAUS|MACON1_RXPAUS);
	// bring MAC out of reset
	enc28j60Write(MACON2, 0x00);
	// enable automatic padding to 60bytes and CRC operations
	enc28j60WriteOp(ENC28J60_BIT_FIELD_SET, MACON3, MACON3_PADCFG0|MACON3_TXCRCEN|MACON3_FRMLNEN);
	// set inter-frame gap (non-back-to-back)
	enc28j60Write(MAIPGL, 0x12);
	enc28j60Write(MAIPGH, 0x0C);
	// set inter-frame gap (back-to-back)
	enc28j60Write(MABBIPG, 0x12);
	// Set the maximum packet size which the controller will accept
        // Do not send packets longer than MAX_FRAMELEN:
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
}

// read the revision of the chip:
uint8_t enc28j60getrev(void)
{
	return(enc28j60Read(EREVID));
}

void enc28j60PacketSend(uint16_t len, uint8_t* packet)
{
	// Set the write pointer to start of transmit buffer area
	enc28j60Write(EWRPTL, TXSTART_INIT&0xFF);
	enc28j60Write(EWRPTH, TXSTART_INIT>>8);
	// Set the TXND pointer to correspond to the packet size given
	enc28j60Write(ETXNDL, (TXSTART_INIT+len)&0xFF);
	enc28j60Write(ETXNDH, (TXSTART_INIT+len)>>8);
	// write per-packet control byte (0x00 means use macon3 settings)
	enc28j60WriteOp(ENC28J60_WRITE_BUF_MEM, 0, 0x00);
	// copy the packet into the transmit buffer
	enc28j60WriteBuffer(len, packet);
	// send the contents of the transmit buffer onto the network
	enc28j60WriteOp(ENC28J60_BIT_FIELD_SET, ECON1, ECON1_TXRTS);
        // Reset the transmit logic problem. See Rev. B4 Silicon Errata point 12.
	if( (enc28j60Read(EIR) & EIR_TXERIF) ){
                enc28j60WriteOp(ENC28J60_BIT_FIELD_CLR, ECON1, ECON1_TXRTS);
        }
}

void enc28j60PacketSendTwo(uint16_t len1, uint8_t* packet1, uint16_t len2, uint8_t* packet2)
{
	//Errata: Transmit Logic reset
	enc28j60WriteOp(ENC28J60_BIT_FIELD_SET, ECON1, ECON1_TXRST);
	enc28j60WriteOp(ENC28J60_BIT_FIELD_CLR, ECON1, ECON1_TXRST);

	// Set the write pointer to start of transmit buffer area
	enc28j60Write(EWRPTL, TXSTART_INIT&0xff);
	enc28j60Write(EWRPTH, TXSTART_INIT>>8);
	// Set the TXND pointer to correspond to the packet size given
	enc28j60Write(ETXNDL, (TXSTART_INIT+len1+len2));
	enc28j60Write(ETXNDH, (TXSTART_INIT+len1+len2)>>8);

	// write per-packet control byte
	enc28j60WriteOp(ENC28J60_WRITE_BUF_MEM, 0, 0x00);

	// copy the packet into the transmit buffer
	enc28j60WriteBuffer(len1, packet1);
	if(len2>0) enc28j60WriteBuffer(len2, packet2);
	
	// send the contents of the transmit buffer onto the network
	enc28j60WriteOp(ENC28J60_BIT_FIELD_SET, ECON1, ECON1_TXRTS);
}

// Gets a packet from the network receive buffer, if one is available.
// The packet will by headed by an ethernet header.
//      maxlen  The maximum acceptable length of a retrieved packet.
//      packet  Pointer where packet data should be stored.
// Returns: Packet length in bytes if a packet was retrieved, zero otherwise.
uint16_t enc28j60PacketReceive(uint16_t maxlen, uint8_t* packet)
{
	uint16_t rxstat;
	uint16_t len;
	// check if a packet has been received and buffered
	//if( !(enc28j60Read(EIR) & EIR_PKTIF) ){
        // The above does not work. See Rev. B4 Silicon Errata point 6.
	if( enc28j60Read(EPKTCNT) ==0 ){
		return(0);
        }

	// Set the read pointer to the start of the received packet
	enc28j60Write(ERDPTL, (NextPacketPtr));
	enc28j60Write(ERDPTH, (NextPacketPtr)>>8);
	// read the next packet pointer
	NextPacketPtr  = enc28j60ReadOp(ENC28J60_READ_BUF_MEM, 0);
	NextPacketPtr |= enc28j60ReadOp(ENC28J60_READ_BUF_MEM, 0)<<8;
	// read the packet length (see datasheet page 43)
	len  = enc28j60ReadOp(ENC28J60_READ_BUF_MEM, 0);
	len |= enc28j60ReadOp(ENC28J60_READ_BUF_MEM, 0)<<8;
        len-=4; //remove the CRC count
	// read the receive status (see datasheet page 43)
	rxstat  = enc28j60ReadOp(ENC28J60_READ_BUF_MEM, 0);
	rxstat |= enc28j60ReadOp(ENC28J60_READ_BUF_MEM, 0)<<8;
	// limit retrieve length
        if (len>maxlen-1){
                len=maxlen-1;
        }
        // check CRC and symbol errors (see datasheet page 44, table 7-3):
        // The ERXFCON.CRCEN is set by default. Normally we should not
        // need to check this.
        if ((rxstat & 0x80)==0){
                // invalid
                len=0;
        }else{
                // copy the packet from the receive buffer
                enc28j60ReadBuffer(len, packet);
        }
	// Move the RX read pointer to the start of the next received packet
	// This frees the memory we just read out
	enc28j60Write(ERXRDPTL, (NextPacketPtr));
	enc28j60Write(ERXRDPTH, (NextPacketPtr)>>8);
	// decrement the packet counter indicate we are done with this packet
	enc28j60WriteOp(ENC28J60_BIT_FIELD_SET, ECON2, ECON2_PKTDEC);
	return(len);
}


/*struct igordev igordev_ethernet = {
	.init = nicInit,
	.deinit = nicDeinit,
	.read = nicRead,
	.write = nicWrite,
	.read_status = nicReadStatus,
	.write_status = nicWriteStatus,
	.idata = &idata
};*/
