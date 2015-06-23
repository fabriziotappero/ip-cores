/*--------------------------------------------------------------------
 * TITLE: etermip
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 6/13/07
 * FILENAME: etermip.c
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    A terminal program supporting downloading new Plasma applications
 *    and Ethernet packet transfers.  Based on WinPcap example code.
 *    Requires WinPcap library at http://www.winpcap.org/.
 *--------------------------------------------------------------------*/
#pragma warning(disable:4996) //kbhit(), getch()
#define _CRT_SECURE_NO_WARNINGS 
#undef UNICODE
#include <windows.h>
#include <stdio.h>
#include <conio.h>

//#define SIMULATE_PLASMA
//#define USE_WPCAP
#ifdef SIMULATE_PLASMA
#define USE_WPCAP
#endif

#ifdef USE_WPCAP
#if 0
   #include "pcap.h"
#else
   //From "pcap.h"
   #define PCAP_ERRBUF_SIZE 256
   typedef struct pcap_if {
      struct pcap_if *next;
      char *name;		/* name to hand to "pcap_open_live()" */
      char *description;	/* textual description of interface, or NULL */
      struct pcap_addr *addresses;
      unsigned long flags;	/* PCAP_IF_ interface flags */
   } pcap_if_t;
   struct pcap_pkthdr {
      struct timeval ts;	/* time stamp */
      unsigned long caplen;	/* length of portion present */
      unsigned long len;	/* length this packet (off wire) */
   };
   typedef struct pcap pcap_t;

   int pcap_findalldevs(pcap_if_t **, char *);
   void pcap_freealldevs(pcap_if_t *);
   pcap_t *pcap_open_live(const char *, int, int, int, char *);
   int pcap_setnonblock(pcap_t *, int, char *);
   int pcap_sendpacket(pcap_t *, const u_char *, int);
   const unsigned char *pcap_next(pcap_t *, struct pcap_pkthdr *);
#endif

//ETHER FIELD                 OFFSET   LENGTH   VALUE
#define ETHERNET_DEST         0        //6
#define ETHERNET_SOURCE       6        //6
#define ETHERNET_FRAME_TYPE   12       //2      IP=0x0800; ARP=0x0806
#define IP_PROTOCOL           23       //1      TCP=0x06;PING=0x01;UDP=0x11
#define IP_SOURCE             26       //4
#define PACKET_SIZE           600

static const unsigned char ethernetAddressNull[] =    {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
static const unsigned char ethernetAddressPhantom[] = {0x00, 0x10, 0xdd, 0xce, 0x15, 0xd4};
static const unsigned char ethernetAddressPhantom2[] = {0x00, 0x10, 0xdd, 0xce, 0x15, 0xd5};

static pcap_t *adhandle;
#endif //USE_WPCAP

static HANDLE serial_handle;
static int PacketBytes, PacketLength, PacketChecksum, Checksum;
static int ChecksumOk, ChecksumError;
static unsigned char PacketData[2000];
static int EthernetActive;

#ifdef SIMULATE_PLASMA
   extern void *IPFrameGet(int freeCount);
   extern int IPProcessEthernetPacket(void *frameIn, int length);
   extern void IPTick(void);
   extern void IPInit(void (*frameSendFunction)(const unsigned char *, int), 
                      unsigned char macAddress[6], char name[6]);
   extern void HtmlInit(int UseFiles);
   extern void ConsoleInit(void);
   static void *ethFrame;
#endif


#ifdef USE_WPCAP
int WinPcapInit(void)
{
	pcap_if_t *alldevs;
	pcap_if_t *d;
	int inum;
	int i=0;
   int choice = -1;
	char errbuf[PCAP_ERRBUF_SIZE];

   /* Retrieve the device list */
	if(pcap_findalldevs(&alldevs, errbuf) == -1)
	{
		printf("Error in pcap_findalldevs: %s\n", errbuf);
		exit(1);
	}
	
	/* Print the list */
	for(d = alldevs; d; d=d->next)
	{
		printf("%d. %s", ++i, d->name);
		if (d->description)
			printf(" (%s)\n", d->description);
		else
			printf(" (No description available)\n");
      if(strstr(d->description, "eneric") == 0 && strstr(d->description, "Linux") == 0)
      {
         if(choice == -1)
            choice = i;
         else
            choice = -2;
      }
	}
	
	if(i==0)
	{
		printf("\nNo interfaces found! Make sure WinPcap is installed.\n");
		return -1;
	}
	
   if(choice >= 0)
      inum = choice;
   else if(i == 1)
      inum = 1;
   else
   {
	   printf("Enter the interface number (1-%d):",i);
	   scanf("%d", &inum);
   }
   printf("inum = %d\n", inum);
	
	if(inum < 1 || inum > i)
	{
		printf("\nInterface number out of range.\n");
		/* Free the device list */
		pcap_freealldevs(alldevs);
		return -1;
	}
	
	/* Jump to the selected adapter */
	for(d=alldevs, i=0; i< inum-1 ;d=d->next, i++);
	
	/* Open the adapter */
	if ((adhandle = pcap_open_live(d->name,	// name of the device
                                       65536,   // 65536 grants that the whole packet will be captured on all the MACs.
                                       1,       // promiscuous mode (nonzero means promiscuous)
                                       10,      // read timeout
                                       errbuf   // error buffer
                                       )) == NULL)
	{
		printf("\nUnable to open the adapter. %s is not supported by WinPcap\n", d->name);
		/* Free the device list */
		pcap_freealldevs(alldevs);
		return -1;
	}
	
	printf("\nlistening on %s...\n", d->description);
	
	/* At this point, we don't need any more the device list. Free it */
	pcap_freealldevs(alldevs);
 
   /* start the capture */
   pcap_setnonblock(adhandle, 1, errbuf);

   return 0;
}


void EthernetSendPacket(const unsigned char *packet, int length)
{
   if(EthernetActive == 0)
      WinPcapInit();
   EthernetActive = 1;
   //if((rand() % 8) == 0) return;
   pcap_sendpacket(adhandle, packet, length);
}


/* Callback function invoked by libpcap for every incoming packet */
void packet_handler(u_char *param, const struct pcap_pkthdr *header, const u_char *pkt_data)
{
#ifndef SIMULATE_PLASMA
   int i, checksum;
   unsigned char buf[80];
   DWORD count;
#else
   int rc;
#endif
   (void)param;

   if(EthernetActive == 0 || header->len > PACKET_SIZE)
      return;
   if(pkt_data[ETHERNET_FRAME_TYPE] != 0x08)
      return;  //not IP or ARP
   if(pkt_data[ETHERNET_FRAME_TYPE+1] != 0x00 &&
      pkt_data[ETHERNET_FRAME_TYPE+1] != 0x06)
      return;  //not IP or ARP
   if(memcmp(pkt_data, ethernetAddressNull, 6) &&      //not broadcast address
      memcmp(pkt_data+ETHERNET_DEST, ethernetAddressPhantom, 6) &&
      memcmp(pkt_data+ETHERNET_DEST, ethernetAddressPhantom2, 6))
      return;

#ifndef SIMULATE_PLASMA
   //Send the ethernet packet over the serial port
   buf[0] = 0xff;
   buf[1] = (unsigned char)(header->len >> 8);
   buf[2] = (unsigned char)header->len;
   checksum = 0;
   for(i = 0; i < (int)header->len; ++i)
      checksum += pkt_data[i];
   buf[3] = (unsigned char)checksum;
   WriteFile(serial_handle, buf, 4, &count, NULL);
   WriteFile(serial_handle, pkt_data, header->len, &count, NULL);
#else
   if(ethFrame == NULL)
      ethFrame = IPFrameGet(0);
   if(ethFrame == NULL)
      return;
   memcpy(ethFrame, pkt_data, header->len);
   rc = IPProcessEthernetPacket(ethFrame, header->len);
   if(rc)
      ethFrame = NULL;
#endif
}


static void UartPacketRead(int value)
{
   if(PacketBytes == 0 && value == 0xff)
   {
      ++PacketBytes;
   }
   else if(PacketBytes == 1)
   {
      ++PacketBytes;
      PacketLength = value << 8;
   }
   else if(PacketBytes == 2)
   {
      ++PacketBytes;
      PacketLength |= value;
      if(PacketLength > 1000)
      {
         PacketBytes = 0;
         printf("Eterm Length Bad! (%d)\n", PacketLength);
      }
   }
   else if(PacketBytes == 3)
   {
      ++PacketBytes;
      PacketChecksum = value;
      Checksum = 0;
   }
   else if(PacketBytes >= 4)
   {
      if(PacketBytes - 4 < sizeof(PacketData))
         PacketData[PacketBytes - 4] = (unsigned char)value;
      Checksum += value;
      ++PacketBytes;
      if(PacketBytes - 4 >= PacketLength)
      {
         if((unsigned char)Checksum == PacketChecksum)
         {
            ++ChecksumOk;
            EthernetSendPacket(PacketData, PacketLength);
         }
         else
         {
            ++ChecksumError;
            //printf("ChecksumError(%d %d)!\n", ChecksumOk, ChecksumError);
         }
         PacketBytes = 0;
      }
   }
}
#endif //USE_WPCAP

/**************************************************************/

long SerialOpen(char *name, long baud)
{
   DCB dcb;
   COMMTIMEOUTS comm_timeouts;
   BOOL rc;
   printf("%s:", name);
   serial_handle = CreateFile(name, GENERIC_READ|GENERIC_WRITE,
      0, NULL, OPEN_EXISTING, 0, NULL);
   if(serial_handle == INVALID_HANDLE_VALUE) 
   {
      printf("no");
      return -1;
   }
   rc = SetupComm(serial_handle, 16000, 16000);
   if(rc == FALSE) 
      printf("ERROR1\n");
   rc = GetCommState(serial_handle, &dcb);
   if(rc == FALSE) 
      printf("ERROR2\n");
   dcb.BaudRate = baud;
   dcb.fBinary = 1;
   dcb.fParity = 0;
   dcb.ByteSize = 8;
   dcb.StopBits = 0; //ONESTOPBIT;
   dcb.fOutX = 0;
   dcb.fInX = 0;
   dcb.fNull = 0;
   dcb.Parity = 0;
   dcb.fOutxCtsFlow = 0;
   dcb.fOutxDsrFlow = 0;
   dcb.fOutX = 0;
   dcb.fInX = 0;
   dcb.fRtsControl = 0;
   dcb.fDsrSensitivity = 0;
   rc = SetCommState(serial_handle, &dcb);
   if(rc == FALSE) 
      printf("ERROR3\n");
   rc = GetCommTimeouts(serial_handle, &comm_timeouts);
   if(rc == FALSE) 
      printf("ERROR4\n");
   comm_timeouts.ReadIntervalTimeout = MAXDWORD;  //non-blocking read
   comm_timeouts.ReadTotalTimeoutMultiplier = 0;
   comm_timeouts.ReadTotalTimeoutConstant = 0;
   comm_timeouts.WriteTotalTimeoutMultiplier = 0;  //blocking write
   comm_timeouts.WriteTotalTimeoutConstant = 0;
   rc = SetCommTimeouts(serial_handle, &comm_timeouts);
   if(rc == FALSE) 
      printf("ERROR5\n");
   printf("OK");
   return(0);
}


long SerialRead(unsigned char *data, unsigned long length)
{
   DWORD count, bytes;
   unsigned char buf[8];

   count = 0;
   for(;;)
   {
      ReadFile(serial_handle, buf, 1, &bytes, NULL);
      if(bytes == 0)
         break;
#ifdef USE_WPCAP
      if(buf[0] == 0xff || PacketBytes)
         UartPacketRead(buf[0]);
      else
#endif
         data[count++] = buf[0];
      if(count >= length)
         break;
   }
   return count;
}

//****************************************************

#define BUF_SIZE 1024*1024
void SendFile(void)
{
   FILE *in;
   unsigned char *buf;
   long length;
   DWORD count;

   in=fopen("test.bin", "rb");
   if(in==NULL) {
      printf("Can't find test.bin\n");
      return;
   }
   buf = (unsigned char*)malloc(BUF_SIZE);
   memset(buf, 0, BUF_SIZE);
   length = (int)fread(buf, 1, BUF_SIZE, in);
   fclose(in);
   printf("Sending test.bin (length=%d bytes) to target...\n", length);
   WriteFile(serial_handle, buf, length, &count, NULL);
   printf("Done downloading\n");
   free(buf);
}


int main(int argc, char *argv[])
{
   unsigned int ticksLast = GetTickCount();
   int length;
   unsigned char buf[80];
   int i, rc;
   char name[80];
   DWORD count;
   unsigned int ticks;
   int downloadSkip = 0;
   (void)argc;
   (void)argv;
   (void)i;
   (void)rc;
   (void)name;

   //WinPcapInit();
#ifndef SIMULATE_PLASMA
   printf("Trying ");
   for(i = 1; i < 20; ++i)
   {
      sprintf(name, "COM%d", i);
      rc = SerialOpen(name, 57600);
      if(rc == 0)
         break;
      printf(" ");
   }
   printf("\n");
   if(argc != 2 || strcmp(argv[1], "none"))
      SendFile();
   else
      downloadSkip = 1;
#else
   IPInit(EthernetSendPacket, NULL, NULL);
   HtmlInit(1);
   ConsoleInit();
#endif

   for(;;)
   {
      // Read keypresses
      while(kbhit())
      {
         buf[0] = (unsigned char)getch();
         if(downloadSkip && buf[0] == '`')
            SendFile();
         WriteFile(serial_handle, buf, 1, &count, NULL);
      }

      // Read UART
      for(;;)
      {
         length = SerialRead(buf, sizeof(buf));
         if(length == 0)
            break;
         buf[length] = 0;
         printf("%s", buf);
      }

#ifdef USE_WPCAP
      // Read Ethernet
      while(EthernetActive)
      {
         struct pcap_pkthdr header;
         const u_char *pkt_data;
         pkt_data = pcap_next(adhandle, &header);
         if(pkt_data == NULL)
            break;
         if(EthernetActive)
            packet_handler(NULL, &header, pkt_data);
      }
#endif
      Sleep(10);
      ticks = GetTickCount();
      if(ticks - ticksLast > 1000)
      {
#ifdef SIMULATE_PLASMA
         IPTick();
#endif
         ticksLast = ticks;
      }
   }
}

