/*--------------------------------------------------------------------
 * TITLE: Plasma Ethernet MAC
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 1/12/08
 * FILENAME: ethernet.c
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Ethernet MAC implementation.
 *    Data is received from the Ethernet PHY four bits at a time. 
 *    After 32-bits are received they are written to 0x13ff0000 + N.  
 *    The data is received LSB first for each byte which requires the
 *    nibbles to be swapped.
 *    Transmit data is read from 0x13fe0000.  Write length/4+1 to
 *    ETHERNET_REG to start transfer.
 *--------------------------------------------------------------------*/
#include "plasma.h"
#include "rtos.h"
#include "tcpip.h"

#define POLYNOMIAL  0x04C11DB7   //CRC bit 33 is truncated
#define TOPBIT      (1<<31)
#define BYTE_EMPTY  0xde         //Data copied into receive buffer
#define COUNT_EMPTY 16           //Count to decide there isn't data
#define INDEX_MASK  0xffff       //Size of receive buffer

static unsigned char gDestMac[]={0x5d, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
static unsigned int CrcTable[256];
static unsigned char reflect[256];
static unsigned char reflectNibble[256];
static OS_Semaphore_t *SemEthernet, *SemEthTransmit;
static int gIndex;          //byte index into 0x13ff0000 receive buffer
static int gCrcChecked;
static volatile int ethTxBusy;


//Read received data from 0x13ff0000.  Data starts with 0x5d+MACaddress.
//Data is being received while processing the data.  Therefore,
//all errors require waiting and then re-processing the data
//to see if the error is fixed by receiving the rest of the packet.
int EthernetReceive(unsigned char *buffer, int length)
{
   int count;
   int start, i, j, shift, offset, index, emptyCount;
   int byte, byteNext;
   unsigned long crc;
   int byteCrc;
   volatile unsigned char *buf = (unsigned char*)ETHERNET_RECEIVE;
   int packetExpected;
   
   while(ethTxBusy)
      OS_ThreadSleep(1);

   //Find the start of a frame
   packetExpected = MemoryRead(IRQ_STATUS) & IRQ_ETHERNET_RECEIVE;
   MemoryRead(ETHERNET_REG);        //clear receive interrupt
   emptyCount = 0;

   //Find dest MAC address
   for(offset = 0; offset <= INDEX_MASK; ++offset)
   {
      index = (gIndex + offset) & INDEX_MASK;
      byte = buf[index];
      if(byte == 0x5d)  //bit pattern 01011101
      {
         for(i = 1; i < sizeof(gDestMac); ++i)
         {
            j = (index + i) & INDEX_MASK;
            byte = buf[j];
            if(byte != 0xff && byte != gDestMac[i])
               break;
         }
         if(i == sizeof(gDestMac))
            break;    //found dest MAC
         emptyCount = 0;
      }
      else if(byte == BYTE_EMPTY)
      {
         if(packetExpected == 0 && ++emptyCount >= 4)
            return 0;
      }
      else
         emptyCount = 0;
   }
   if(offset > INDEX_MASK)
      return 0;
   while(gIndex != index)
   {
      buf[gIndex] = BYTE_EMPTY;
      gIndex = (gIndex + 1) & INDEX_MASK;
   }

   //Found start of frame.  Now find end of frame and check CRC.
   start = gIndex;
   gIndex = (gIndex + 1) & INDEX_MASK;           //skip 0x5d byte
   crc = 0xffffffff;
   for(count = 0; count < length; )
   {
      byte = buf[gIndex];
      gIndex = (gIndex + 1) & INDEX_MASK;

      byte = ((byte << 4) & 0xf0) | (byte >> 4); //swap nibbles
      buffer[count++] = (unsigned char)byte;
      byte = reflect[byte] ^ (crc >> 24);        //calculate CRC32
      crc = CrcTable[byte] ^ (crc << 8);
      if(count >= 40)
      {
         //Check if CRC matches to detect end of frame
         byteCrc = reflectNibble[crc >> 24];
         byteNext = buf[gIndex];
         if(byteCrc == byteNext)
         {
            for(i = 1; i < 4; ++i)
            {
               shift = 24 - (i << 3);
               byteCrc = reflectNibble[(crc >> shift) & 0xff];
               byteNext = buf[(gIndex + i) & 0xffff];
               if(byteCrc != byteNext)
               {
                  //printf("nope %d %d 0x%x 0x%x\n", count, i, byteCrc, byteNext);
                  i = 99;
               }
            }
            if(i == 4)
            {
               //Found end of frame -- set used bytes to BYTE_EMPTY
               //printf("Found it! %d\n", count);
               gIndex = (gIndex + 4) & INDEX_MASK;
               for(i = 0; i < count+5; ++i)
                  buf[(start + i) & INDEX_MASK] = BYTE_EMPTY;
               while(gIndex & 3)
               {
                  buf[gIndex] = BYTE_EMPTY;
                  gIndex = (gIndex + 1) & INDEX_MASK;
               }
               gCrcChecked = 0;
               return count;
            }
         }
      }
   }
   gIndex = start;
   if(++gCrcChecked > 0)     //if the CPU speed is > 25MHz, change to 1
   {
      buf[gIndex] = BYTE_EMPTY;
      gIndex = (gIndex + 1) & INDEX_MASK;
   }
   return -1;
}


//Copy transmit data to 0x13fe0000 with preamble and CRC32
void EthernetTransmit(unsigned char *buffer, int length)
{
   int i, byte, shift;
   unsigned long crc;
   volatile unsigned char *buf = (unsigned char*)ETHERNET_TRANSMIT;

   OS_SemaphorePend(SemEthTransmit, OS_WAIT_FOREVER);
   ethTxBusy = 1;

   //Wait for previous transfer to complete
   for(i = 0; i < 10000; ++i)
   {
      if(MemoryRead(IRQ_STATUS) & IRQ_ETHERNET_TRANSMIT)
         break;
   }

   Led(2, 2);
   while(length < 60 || (length & 3) != 0)
      buffer[length++] = 0;

   //Start of Ethernet frame
   for(i = 0; i < 7; ++i)
      buf[i] = 0x55;
   buf[7] = 0x5d;

   //Calculate CRC32
   crc = 0xffffffff;
   for(i = 0; i < length; ++i)
   {
      byte = buffer[i];
      buf[i + 8] = (unsigned char)((byte << 4) | (byte >> 4)); //swap nibbles
      byte = reflect[byte] ^ (crc >> 24);        //calculate CRC32
      crc = CrcTable[byte] ^ (crc << 8);
   }

   //Output CRC32
   for(i = 0; i < 4; ++i)
   {
      shift = 24 - (i << 3);
      byte = reflectNibble[(crc >> shift) & 0xff];
      buf[length + 8 + i] = (unsigned char)byte;
   }

   //Start transfer
   length = (length + 12 + 4) >> 2;
   MemoryWrite(ETHERNET_REG, length);
   Led(2, 0);

   //Wait for previous transfer to complete
   for(i = 0; i < 10000; ++i)
   {
      if(MemoryRead(IRQ_STATUS) & IRQ_ETHERNET_TRANSMIT)
         break;
   }
   ethTxBusy = 0;

   OS_SemaphorePost(SemEthTransmit);
}


void EthernetThread(void *arg)
{
   int length;
   int rc;
   unsigned int ticks, ticksLast=0;
   IPFrame *ethFrame=NULL;
   (void)arg;

   for(;;)
   {
      OS_InterruptMaskSet(IRQ_ETHERNET_RECEIVE);    //enable interrupt
      OS_SemaphorePend(SemEthernet, 50);            //wait for interrupt

      //Process all received packets
      for(;;)
      {
         if(ethFrame == NULL)
            ethFrame = IPFrameGet(FRAME_COUNT_RCV);
         if(ethFrame == NULL)
            break;
         length = EthernetReceive(ethFrame->packet, PACKET_SIZE);
         if(length == 0)
            break;         //no packet found
         if(length < 0)
            continue;      //CRC didn't match; process next packet
         Led(1, 1);
         rc = IPProcessEthernetPacket(ethFrame, length);
         Led(1, 0);
         if(rc)
            ethFrame = NULL;
      }

      ticks = OS_ThreadTime();
      if(ticks - ticksLast >= 50)
      {
         IPTick();
         ticksLast = ticks;
      }
   }
}


void EthernetIsr(void *arg)
{
   (void)arg;
   OS_InterruptMaskClear(IRQ_ETHERNET_RECEIVE);
   OS_SemaphorePost(SemEthernet);
}


/******************* CRC32 calculations **********************
 * The CRC32 code is modified from Michael Barr's article in 
 * Embedded Systems Programming January 2000.
 * A CRC is really modulo-2 binary division.  Substraction means XOR. */
static unsigned int Reflect(unsigned int value, int bits)
{
   unsigned int num=0;
   int i;
   for(i = 0; i < bits; ++i)
   {
      num = (num << 1) | (value & 1);
      value >>= 1;
   }
   return num;
}


static void CrcInit(void)
{
   unsigned int remainder;
   int dividend, bit, i;

   //Compute the remainder of each possible dividend
   for(dividend = 0; dividend < 256; ++dividend)
   {
      //Start with the dividend followed by zeros
      remainder = dividend << 24;
      //Perform modulo-2 division, a bit at a time
      for(bit = 8; bit > 0; --bit)
      {
         //Try to divide the current data bit
         if(remainder & TOPBIT)
            remainder = (remainder << 1) ^ POLYNOMIAL;
         else
            remainder = remainder << 1;
      }
      CrcTable[dividend] = remainder;
   }
   for(i = 0; i < 256; ++i)
   {
      reflect[i] = (unsigned char)Reflect(i, 8);
      reflectNibble[i] = (unsigned char)((Reflect((i >> 4) ^ 0xf, 4) << 4) | 
         Reflect(i ^ 0xf, 4));
   }
}


static void SpinWait(int clocks)
{
   int value = *(volatile int*)COUNTER_REG + clocks;
   while(*(volatile int*)COUNTER_REG - value < 0)
      ;
}


//Use the Ethernet MDIO bus to configure the Ethernet PHY
static int EthernetConfigure(int index, int value)
{
   unsigned int data;
   int i, bit, rc=0;
   
   //Format of SMI data: 0101 A4:A0 R4:R0 00 D15:D0
   if(value <= 0xffff)
      data = 0x5f800000;  //write
   else
      data = 0x6f800000;  //read
   data |= index << 18 | value;
   
   MemoryWrite(GPIO0_SET, ETHERNET_MDIO | ETHERNET_MDIO_WE | ETHERNET_MDC);
   for(i = 0; i < 34; ++i)
   {
      MemoryWrite(GPIO0_SET, ETHERNET_MDC);    //clock high
      SpinWait(10);
      MemoryWrite(GPIO0_CLEAR, ETHERNET_MDC);  //clock low
      SpinWait(10);
   }
   for(i = 31; i >= 0; --i)
   {
      bit = (data >> i) & 1;
      if(bit)
         MemoryWrite(GPIO0_SET, ETHERNET_MDIO);
      else
         MemoryWrite(GPIO0_CLEAR, ETHERNET_MDIO);
      SpinWait(10);         
      MemoryWrite(GPIO0_SET, ETHERNET_MDC);    //clock high
      SpinWait(10);
      rc = rc << 1 | ((MemoryRead(GPIOA_IN) >> 13) & 1);
      MemoryWrite(GPIO0_CLEAR, ETHERNET_MDC);  //clock low
      SpinWait(10);
      if(value > 0xffff && i == 17)
         MemoryWrite(GPIO0_CLEAR, ETHERNET_MDIO_WE);
   }
   MemoryWrite(GPIO0_CLEAR, ETHERNET_MDIO | ETHERNET_MDIO_WE | ETHERNET_MDC);
   return (rc >> 1) & 0xffff;
}


void EthernetInit(unsigned char MacAddress[6])
{
   int i, value;
   volatile unsigned char *buf = (unsigned char*)ETHERNET_RECEIVE;

   CrcInit();
   if(MacAddress)
   {
      for(i = 0; i < 6; ++i)
      {
         value = MacAddress[i];
         gDestMac[i+1] = (unsigned char)((value >> 4) | (value << 4));
      }
   }

   EthernetConfigure(4, 0x0061);        //advertise 10Base-T full duplex
   EthernetConfigure(0, 0x1300);        //start auto negotiation
#if 0
   OS_ThreadSleep(100);
   printf("reg4=0x%x (0x61)\n", EthernetConfigure(4, 0x10000));
   printf("reg0=0x%x (0x1100)\n", EthernetConfigure(0, 0x10000));
   printf("reg1=status=0x%x (0x7809)\n", EthernetConfigure(1, 0x10000));
   printf("reg5=partner=0x%x (0x01e1)\n", EthernetConfigure(5, 0x10000));
#endif

   MemoryWrite(GPIO0_CLEAR, ETHERNET_ENABLE);
   
   //Clear receive buffer
   for(i = 0; i <= INDEX_MASK; ++i)
      buf[i] = BYTE_EMPTY;

   if(SemEthernet == NULL)
   {
      SemEthernet = OS_SemaphoreCreate("eth", 0);
      SemEthTransmit = OS_SemaphoreCreate("ethT", 1);
      OS_ThreadCreate("eth", EthernetThread, NULL, 240, 0);
   }

   //Setup interrupts for receiving data
   OS_InterruptRegister(IRQ_ETHERNET_RECEIVE, EthernetIsr);

   //Start receive DMA
   MemoryWrite(GPIO0_SET, ETHERNET_ENABLE);
}

