/*--------------------------------------------------------------------
 * TITLE: Plasma TCP/IP Protocol Stack
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 4/22/06
 * FILENAME: tcpip.c
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Plasma TCP/IP Protocol Stack
 *
 *    Possible call stack when receiving a packet:
 *       IPMainThread()
 *          IPProcessEthernetPacket()
 *             IPProcessTCPPacket()
 *                TCPSendPacket()
 *                   IPSendPacket()
 *                      IPChecksum()
 *                      IPSendFrame()
 *                         FrameInsert()
 *--------------------------------------------------------------------*/
#include "rtos.h"
#define INSIDE_TCPIP
#include "tcpip.h"

//ETHER FIELD                 OFFSET   LENGTH   VALUE
#define ETHERNET_DEST         0        //6
#define ETHERNET_SOURCE       6        //6
#define ETHERNET_FRAME_TYPE   12       //2      IP=0x0800; ARP=0x0806

//ARP   FIELD                 OFFSET   LENGTH   VALUE
#define ARP_HARD_TYPE         14       //2      0x0001
#define ARP_PROT_TYPE         16       //2      0x0800
#define ARP_HARD_SIZE         18       //1      0x06
#define ARP_PROT_SIZE         19       //1      0x04
#define ARP_OP                20       //2      ARP=1;ARPreply=2
#define ARP_ETHERNET_SENDER   22       //6
#define ARP_IP_SENDER         28       //4
#define ARP_ETHERNET_TARGET   32       //6
#define ARP_IP_TARGET         38       //4
#define ARP_PAD               42       //18     0

//IP    FIELD                 OFFSET   LENGTH   VALUE
#define IP_VERSION_LENGTH     14       //1      0x45
#define IP_TYPE_OF_SERVICE    15       //1      0x00
#define IP_LENGTH             16       //2
#define IP_ID16               18       //2
#define IP_FRAG_OFFSET        20       //2
#define IP_TIME_TO_LIVE       22       //1      0x80
#define IP_PROTOCOL           23       //1      TCP=0x06;PING=0x01;UDP=0x11
#define IP_CHECKSUM           24       //2
#define IP_SOURCE             26       //4
#define IP_DEST               30       //4

//PSEUDO FIELD                OFFSET   LENGTH   VALUE
#define PSEUDO_IP_SOURCE      0        //4
#define PSEUDO_IP_DEST        4        //4
#define PSEUDO_ZERO           8        //1      0
#define PSEUDO_IP_PROTOCOL    9        //1
#define PSEUDO_LENGTH         10       //2

//UDP   FIELD                 OFFSET   LENGTH   VALUE
#define UDP_SOURCE_PORT       34       //2
#define UDP_DEST_PORT         36       //2
#define UDP_LENGTH            38       //2
#define UDP_CHECKSUM          40       //2
#define UDP_DATA              42

//DHCP  FIELD                 OFFSET   LENGTH   VALUE
#define DHCP_OPCODE           42       //1      REQUEST=1;REPLY=2
#define DHCP_HW_TYPE          43       //1      1
#define DHCP_HW_LEN           44       //1      6
#define DHCP_HOP_COUNT        45       //1      0
#define DHCP_TRANS_ID         46       //4
#define DHCP_NUM_SEC          50       //2      0
#define DHCP_UNUSED           52       //2
#define DHCP_CLIENT_IP        54       //4
#define DHCP_YOUR_IP          58       //4
#define DHCP_SERVER_IP        62       //4
#define DHCP_GATEWAY_IP       66       //4
#define DHCP_CLIENT_ETHERNET  70       //16
#define DHCP_SERVER_NAME      86       //64
#define DHCP_BOOT_FILENAME    150      //128
#define DHCP_MAGIC_COOKIE     278      //4      0x63825363
#define DHCP_OPTIONS          282      //N

#define DHCP_MESSAGE_TYPE     53       //1 type
#define DHCP_DISCOVER         1
#define DHCP_OFFER            2
#define DHCP_REQUEST          3
#define DHCP_ACK              5
#define DHCP_REQUEST_IP       50       //4 ip
#define DHCP_REQUEST_SERV_IP  54       //4 ip
#define DHCP_CLIENT_ID        61       //7 1 ethernet
#define DHCP_HOST_NAME        12       //6 plasma
#define DHCP_PARAMS           55       //4 1=subnet; 15=domain_name; 3=router; 6=dns
#define DHCP_PARAM_SUBNET     1
#define DHCP_PARAM_ROUTER     3
#define DHCP_PARAM_DNS        6
#define DHCP_END_OPTION       0xff

//DHCP  FIELD                 OFFSET   LENGTH   VALUE
#define DNS_ID                0        //2    
#define DNS_FLAGS             2        //2      
#define DNS_NUM_QUESTIONS     4        //2      1 
#define DNS_NUM_ANSWERS_RR    6        //2      0/1
#define DNS_NUM_AUTHORITY_RR  8        //2      0 
#define DNS_NUM_ADDITIONAL_RR 10       //2      0
#define DNS_QUESTIONS         12       //2   

#define DNS_FLAGS_RESPONSE    0x8000
#define DNS_FLAGS_RECURSIVE   0x0100
#define DNS_FLAGS_ERROR       0x0003
#define DNS_FLAGS_OK          0x0000
#define DNS_QUERY_TYPE_IP     1
#define DNS_QUERY_CLASS       1
#define DNS_PORT              53

//TCP   FIELD                 OFFSET   LENGTH   VALUE
#define TCP_SOURCE_PORT       34       //2
#define TCP_DEST_PORT         36       //2
#define TCP_SEQ               38       //4
#define TCP_ACK               42       //4
#define TCP_HEADER_LENGTH     46       //1      0x50
#define TCP_FLAGS             47       //1      SYNC=0x2;ACK=0x10;FIN=0x1
#define TCP_WINDOW_SIZE       48       //2
#define TCP_CHECKSUM          50       //2
#define TCP_URGENT_POINTER    52       //2
#define TCP_DATA              54       //length-N

#define TCP_FLAGS_FIN         1
#define TCP_FLAGS_SYN         2
#define TCP_FLAGS_RST         4
#define TCP_FLAGS_PSH         8
#define TCP_FLAGS_ACK         16

//PING  FIELD                 OFFSET   LENGTH   VALUE
#define PING_TYPE             34       //1      SEND=8;REPLY=0
#define PING_CODE             35       //1      0
#define PING_CHECKSUM         36       //2
#define PING_ID               38       //2
#define PING_SEQUENCE         40       //2
#define PING_DATA             44

enum {FRAME_FREE=0, FRAME_ACQUIRED=1, FRAME_IN_LIST};

static void IPClose2(IPSocket *Socket);
static void IPArp(unsigned char ipAddress[4]);

typedef struct ArpCache_s {
   unsigned char ip[4];
   unsigned char mac[6];
} ArpCache_t;
static ArpCache_t ArpCache[10];
static int ArpCacheIndex;

static uint8 ethernetAddressGateway[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
#ifndef WIN32
static uint8 ethernetAddressPlasma[] =  {0x00, 0x10, 0xdd, 0xce, 0x15, 0xd4};
#else
static uint8 ethernetAddressPlasma[] =  {0x00, 0x10, 0xdd, 0xce, 0x15, 0xd5};
#endif

static uint8 ipAddressPlasma[] =  {192, 168, 100, 10};      //changed by DHCP
static uint8 ipAddressGateway[] = {0x00, 0x00, 0x00, 0x00}; //changed by DHCP
static uint32 ipAddressDns;                                 //changed by DHCP

static OS_Mutex_t *IPMutex;
static int FrameFreeCount;
static IPFrame *FrameFreeHead;
static IPFrame *FrameSendHead;
static IPFrame *FrameSendTail;
static IPFrame *FrameResendHead;
static IPFrame *FrameResendTail;
static IPSocket *SocketHead;
static uint32 Seconds;
static int DhcpRetrySeconds;
static IPSendFuncPtr FrameSendFunc;
static OS_MQueue_t *IPMQueue;
static OS_Thread_t *IPThread;
int IPVerbose=1;

static const unsigned char dhcpDiscover[] = {
   0xff, 0xff, 0xff, 0xff, 0xff, 0xff,             //dest
   0x00, 0x10, 0xdd, 0xce, 0x15, 0xd4,             //src
   0x08, 0x00, 
   0x45, 0x00, 0x01, 0x48, 0x2e, 0xf5, 0x00, 0x00, //ip
   0x80, 0x11, 0x0a, 0xb1, 0x00, 0x00, 0x00, 0x00, 
   0xff, 0xff, 0xff, 0xff,
   0x00, 0x44, 0x00, 0x43, 0x01, 0x34, 0x45, 0x66, //udp
   0x01, 0x01, 0x06, 0x00, 0x69, 0x26, 0xb5, 0x52  //dhcp
};

static unsigned char dhcpOptions[] = {
   0x63, 0x82, 0x53, 0x63,      //cookie
   0x35, 0x01, 0x01,            //DHCP Discover
   0x3d, 0x07, 0x01, 0x00, 0x10, 0xdd, 0xce, 0x15, 0xd4, //Client identifier
#ifndef WIN32
   0x0c, 0x06, 'p', 'l', 'a', 's', 'm', 'a',             //Host name
#else
   0x0c, 0x06, 'p', 'l', 'a', 's', 'm', 'b',             //Host name
#endif
   0x37, 0x03, DHCP_PARAM_SUBNET, DHCP_PARAM_ROUTER, DHCP_PARAM_DNS, //Parameters
   DHCP_END_OPTION
};


//Get a free frame; can be called from an ISR
IPFrame *IPFrameGet(int freeCount)
{
   IPFrame *frame=NULL;
   uint32 state;

   state = OS_CriticalBegin();
   if(FrameFreeCount >= freeCount)
   {
      frame = FrameFreeHead;
      if(FrameFreeHead)
      {
         FrameFreeHead = FrameFreeHead->next;
         --FrameFreeCount;
      }
   }
   OS_CriticalEnd(state);
   if(frame)
   {
      assert(frame->state == FRAME_FREE);
      frame->state = FRAME_ACQUIRED;
   }
   return frame;
}


static void FrameFree(IPFrame *frame)
{
   uint32 state;

   assert(frame->state == FRAME_ACQUIRED);
   frame->state = FRAME_FREE;
   state = OS_CriticalBegin();
   frame->next = FrameFreeHead;
   FrameFreeHead = frame;
   ++FrameFreeCount;
   OS_CriticalEnd(state);
}


static void FrameInsert(IPFrame **head, IPFrame **tail, IPFrame *frame)
{
   assert(frame->state == FRAME_ACQUIRED);
   frame->state = FRAME_IN_LIST;
   OS_MutexPend(IPMutex);
   frame->prev = NULL;
   frame->next = *head;
   if(*head)
      (*head)->prev = frame;
   *head = frame;
   if(*tail == NULL)
      *tail = frame;
   OS_MutexPost(IPMutex);
}


static void FrameRemove(IPFrame **head, IPFrame **tail, IPFrame *frame)
{
   assert(frame->state == FRAME_IN_LIST);
   if(frame->state != FRAME_IN_LIST)
   {
      printf("frame->state=%d\n", frame->state);
      return;
   }
   frame->state = FRAME_ACQUIRED;
   if(frame->prev)
      frame->prev->next = frame->next;
   else
      *head = frame->next;
   if(frame->next)
      frame->next->prev = frame->prev;
   else
      *tail = frame->prev;
   frame->prev = NULL;
   frame->next = NULL;
}


static int IPChecksum(int checksum, const unsigned char *data, int length)
{
   int i;
   checksum = ~checksum & 0xffff;
   for(i = 0; i < length-1; i += 2)
   {
      checksum += (data[i] << 8) | data[i+1];
   }
   if(i < length)
      checksum += data[i] << 8;
   while(checksum >> 16)
      checksum = (checksum & 0xffff) + (checksum >> 16);
   checksum = ~checksum & 0xffff;
   return checksum;
}


static int EthernetVerifyChecksums(const unsigned char *packet, int length)
{
   int checksum, length2;
   unsigned char pseudo[12];

   //Calculate checksums
   if(packet[ETHERNET_FRAME_TYPE+1] == 0x00)  //IP
   {
      checksum = IPChecksum(0xffff, packet+IP_VERSION_LENGTH, 20);
      if(checksum)
         return -1;
      if(packet[IP_PROTOCOL] == 0x01)         //PING
      {
         checksum = IPChecksum(0xffff, packet+PING_TYPE, length-PING_TYPE);
      }
      else if(packet[IP_PROTOCOL] == 0x11)    //UDP
      {
         if(packet[UDP_CHECKSUM] == 0 && packet[UDP_CHECKSUM+1] == 0)
            return 0;
         memcpy(pseudo+PSEUDO_IP_SOURCE, packet+IP_SOURCE, 4);
         memcpy(pseudo+PSEUDO_IP_DEST, packet+IP_DEST, 4);
         pseudo[PSEUDO_ZERO] = 0;
         pseudo[PSEUDO_IP_PROTOCOL] = packet[IP_PROTOCOL];
         memcpy(pseudo+PSEUDO_LENGTH, packet+UDP_LENGTH, 2);
         checksum = IPChecksum(0xffff, pseudo, 12);
         length2 = (packet[UDP_LENGTH] << 8) + packet[UDP_LENGTH+1];
         checksum = IPChecksum(checksum, packet+UDP_SOURCE_PORT, length2);
      }
      else if(packet[IP_PROTOCOL] == 0x06)    //TCP
      {
         memcpy(pseudo+PSEUDO_IP_SOURCE, packet+IP_SOURCE, 4);
         memcpy(pseudo+PSEUDO_IP_DEST, packet+IP_DEST, 4);
         pseudo[PSEUDO_ZERO] = 0;
         pseudo[PSEUDO_IP_PROTOCOL] = packet[IP_PROTOCOL];
         length = (packet[IP_LENGTH] << 8) + packet[IP_LENGTH+1];
         length2 = length - 20;
         pseudo[PSEUDO_LENGTH] = (unsigned char)(length2 >> 8);
         pseudo[PSEUDO_LENGTH+1] = (unsigned char)length2;
         checksum = IPChecksum(0xffff, pseudo, 12);
         checksum = IPChecksum(checksum, packet+TCP_SOURCE_PORT, length2);
      }
      if(checksum)
         return -1;
   }
   return 0;
}


static void IPFrameReschedule(IPFrame *frame)
{
   int length;
   length = frame->length - TCP_DATA;
   if(frame->packet[TCP_FLAGS] & (TCP_FLAGS_FIN | TCP_FLAGS_SYN))
      ++length;
   if(frame->socket == NULL || frame->socket->state == IP_UDP || length == 0 ||
      frame->socket->state == IP_PING || ++frame->retryCnt > 5)
   {
      FrameFree(frame);     //can't be ACK'ed
   }
#ifdef WIN32
   else if(FrameFreeCount < FRAME_COUNT_SYNC)
   {
      FrameFree(frame);     //can't be ACK'ed
   }
#endif
   else
   {
      //Put on resend list until TCP ACK'ed
      frame->timeout = (short)(RETRANSMIT_TIME * frame->retryCnt);
      FrameInsert(&FrameResendHead, &FrameResendTail, frame);
   }
}


static void IPSendFrame(IPFrame *frame)
{
   uint32 message[4];
   int i;
   unsigned char *packet=frame->packet;

   //Check if MAC address unknown
   if(packet[ETHERNET_FRAME_TYPE+1] == 0x00 && //IP
      packet[ETHERNET_DEST] == 0xff && packet[IP_DEST] != 0xff)
   {
      for(i = 0; i < sizeof(ArpCache) / sizeof(ArpCache_t); ++i)
      {
         if(memcmp(packet+IP_DEST, ArpCache[i].ip, 4) == 0)
         {
            memcpy(packet+ETHERNET_DEST, ArpCache[i].mac, 6);
            if(frame->socket)
               memcpy(frame->socket->headerSend+ETHERNET_DEST, ArpCache[i].mac, 6);
            break;
         }
      }
      if(packet[ETHERNET_DEST] == 0xff)
         IPArp(packet+IP_DEST);
   }

   if(FrameSendFunc)
   {
      //Single threaded
      FrameSendFunc(frame->packet, frame->length);
      IPFrameReschedule(frame);
   }
   else
   {
      //Add Packet to send queue
      FrameInsert(&FrameSendHead, &FrameSendTail, frame);

      //Wakeup sender thread
      message[0] = 2;
      OS_MQueueSend(IPMQueue, message);
   }
}


static void IPSendPacket(IPSocket *socket, IPFrame *frame, int length)
{
   int checksum, length2=length;
   unsigned char pseudo[12], *packet=frame->packet;

   frame->length = (uint16)length;

   //Calculate checksums
   if(packet[ETHERNET_FRAME_TYPE+1] == 0x00)  //IP
   {
      length2 = length - IP_VERSION_LENGTH;
      packet[IP_LENGTH] = (uint8)(length2 >> 8);
      packet[IP_LENGTH+1] = (uint8)length2;
      memset(packet+IP_CHECKSUM, 0, 2);
      checksum = IPChecksum(0xffff, packet+IP_VERSION_LENGTH, 20);
      packet[IP_CHECKSUM] = (unsigned char)(checksum >> 8);
      packet[IP_CHECKSUM+1] = (unsigned char)checksum;
      if(packet[IP_PROTOCOL] == 0x01)         //ICMP & PING
      {
         memset(packet+PING_CHECKSUM, 0, 2);
         checksum = IPChecksum(0xffff, packet+PING_TYPE, length-PING_TYPE);
         packet[PING_CHECKSUM] = (unsigned char)(checksum >> 8);
         packet[PING_CHECKSUM+1] = (unsigned char)checksum;
      }
      else if(packet[IP_PROTOCOL] == 0x11)    //UDP
      {
         length2 = length - UDP_SOURCE_PORT;
         packet[UDP_LENGTH] = (uint8)(length2 >> 8);
         packet[UDP_LENGTH+1] = (uint8)length2;
         memcpy(pseudo+PSEUDO_IP_SOURCE, packet+IP_SOURCE, 4);
         memcpy(pseudo+PSEUDO_IP_DEST, packet+IP_DEST, 4);
         pseudo[PSEUDO_ZERO] = 0;
         pseudo[PSEUDO_IP_PROTOCOL] = packet[IP_PROTOCOL];
         memcpy(pseudo+PSEUDO_LENGTH, packet+UDP_LENGTH, 2);
         checksum = IPChecksum(0xffff, pseudo, 12);
         memset(packet+UDP_CHECKSUM, 0, 2);
         length2 = (packet[UDP_LENGTH] << 8) + packet[UDP_LENGTH+1];
         checksum = IPChecksum(checksum, packet+UDP_SOURCE_PORT, length2);
         packet[UDP_CHECKSUM] = (unsigned char)(checksum >> 8);
         packet[UDP_CHECKSUM+1] = (unsigned char)checksum;
      }
      else if(packet[IP_PROTOCOL] == 0x06)    //TCP
      {
         memcpy(pseudo+PSEUDO_IP_SOURCE, packet+IP_SOURCE, 4);
         memcpy(pseudo+PSEUDO_IP_DEST, packet+IP_DEST, 4);
         pseudo[PSEUDO_ZERO] = 0;
         pseudo[PSEUDO_IP_PROTOCOL] = packet[IP_PROTOCOL];
         length2 = (packet[IP_LENGTH] << 8) + packet[IP_LENGTH+1];
         length2 = length2 - 20;
         pseudo[PSEUDO_LENGTH] = (unsigned char)(length2 >> 8);
         pseudo[PSEUDO_LENGTH+1] = (unsigned char)length2;
         checksum = IPChecksum(0xffff, pseudo, 12);
         memset(packet+TCP_CHECKSUM, 0, 2);
         checksum = IPChecksum(checksum, packet+TCP_SOURCE_PORT, length2);
         packet[TCP_CHECKSUM] = (unsigned char)(checksum >> 8);
         packet[TCP_CHECKSUM+1] = (unsigned char)checksum;
      }
   }

   length2 = length - TCP_DATA;
   if(socket && (packet[TCP_FLAGS] & (TCP_FLAGS_FIN | TCP_FLAGS_SYN)))
      length2 = 1;
   frame->socket = socket;
   frame->timeout = 0;
   frame->retryCnt = 0;
   if(socket)
      frame->seqEnd = socket->seq + length2;
   IPSendFrame(frame);
}


static void TCPSendPacket(IPSocket *socket, IPFrame *frame, int length)
{
   uint8 *packet = frame->packet;
   int flags, count;

   flags = packet[TCP_FLAGS];
   memcpy(packet, socket->headerSend, TCP_SEQ);
   packet[TCP_FLAGS] = (uint8)flags;
   if(flags & TCP_FLAGS_SYN)
      packet[TCP_HEADER_LENGTH] = 0x60;  //set maximum segment size
   else
      packet[TCP_HEADER_LENGTH] = 0x50;
   packet[TCP_SEQ]   = (uint8)(socket->seq >> 24);
   packet[TCP_SEQ+1] = (uint8)(socket->seq >> 16);
   packet[TCP_SEQ+2] = (uint8)(socket->seq >> 8);
   packet[TCP_SEQ+3] = (uint8)socket->seq;
   packet[TCP_ACK]   = (uint8)(socket->ack >> 24);
   packet[TCP_ACK+1] = (uint8)(socket->ack >> 16);
   packet[TCP_ACK+2] = (uint8)(socket->ack >> 8);
   packet[TCP_ACK+3] = (uint8)socket->ack;
   count = RECEIVE_WINDOW - (socket->ack - socket->ackProcessed);
   if(count < 0)
      count = 0;
   packet[TCP_WINDOW_SIZE] = (uint8)(count >> 8);
   packet[TCP_WINDOW_SIZE+1] = (uint8)count;
   packet[TCP_URGENT_POINTER] = 0;
   packet[TCP_URGENT_POINTER+1] = 0;
   IPSendPacket(socket, frame, length);
}


static void EthernetCreateResponse(unsigned char *packetOut,
                                   const unsigned char *packet,
                                   int length)
{
   //Swap destination and source fields
   memcpy(packetOut, packet, length);
   memcpy(packetOut+ETHERNET_DEST, packet+ETHERNET_SOURCE, 6);
   memcpy(packetOut+ETHERNET_SOURCE, packet+ETHERNET_DEST, 6);
   if(packet[ETHERNET_FRAME_TYPE+1] == 0x00)  //IP
   {
      memcpy(packetOut+IP_SOURCE, packet+IP_DEST, 4);
      memcpy(packetOut+IP_DEST, packet+IP_SOURCE, 4);
      if(packet[IP_PROTOCOL] == 0x06 || packet[IP_PROTOCOL] == 0x11)   //TCP/UDP
      {
         memcpy(packetOut+TCP_SOURCE_PORT, packet+TCP_DEST_PORT, 2);
         memcpy(packetOut+TCP_DEST_PORT, packet+TCP_SOURCE_PORT, 2);
      }
   }
}


static void IPArp(unsigned char ipAddress[4])
{
   IPFrame *frame;
   uint8 *packetOut;

   frame = IPFrameGet(0);
   if(frame == NULL)
      return;
   packetOut = frame->packet;
   memset(packetOut, 0, 512);
   memset(packetOut+ETHERNET_DEST, 0xff, 6);
   memcpy(packetOut+ETHERNET_SOURCE, ethernetAddressPlasma, 6);
   packetOut[ETHERNET_FRAME_TYPE] = 0x08;
   packetOut[ETHERNET_FRAME_TYPE+1] = 0x06;
   packetOut[ARP_HARD_TYPE+1] = 0x01;
   packetOut[ARP_PROT_TYPE] = 0x08;
   packetOut[ARP_HARD_SIZE] = 0x06;
   packetOut[ARP_PROT_SIZE] = 0x04;
   packetOut[ARP_OP+1] = 1;
   memcpy(packetOut+ARP_ETHERNET_SENDER, ethernetAddressPlasma, 6);
   memcpy(packetOut+ARP_IP_SENDER, ipAddressPlasma, 4);
   memcpy(packetOut+ARP_IP_TARGET, ipAddress, 4);
   IPSendPacket(NULL, frame, 60);
}


static void IPDhcp(const unsigned char *packet, int length, int state)
{
   uint8 *packetOut, *ptr;
   const uint8 *ptr2;
   IPFrame *frame;
   static int request=0;

   if(state == 1)
   {
      //Create DHCP Discover
      frame = IPFrameGet(0);
      if(frame == NULL)
         return;
      packetOut = frame->packet;
      memset(packetOut, 0, 512);
      memcpy(packetOut, dhcpDiscover, sizeof(dhcpDiscover));
      memcpy(packetOut+ETHERNET_SOURCE, ethernetAddressPlasma, 6);
      memcpy(packetOut+DHCP_CLIENT_ETHERNET, ethernetAddressPlasma, 6);
      memcpy(packetOut+DHCP_MAGIC_COOKIE, dhcpOptions, sizeof(dhcpOptions));
      memcpy(packetOut+DHCP_MAGIC_COOKIE+10, ethernetAddressPlasma, 6);
      IPSendPacket(NULL, frame, 400);
      request = DHCP_DISCOVER;
      DhcpRetrySeconds = 2;
   }
   else if(state == 2 && memcmp(packet+DHCP_CLIENT_ETHERNET, ethernetAddressPlasma, 6) == 0)
   {
      if(packet[DHCP_MAGIC_COOKIE+6] == DHCP_OFFER && request == DHCP_DISCOVER)
      {
         //Process DHCP Offer and send DHCP Request
         frame = IPFrameGet(0);
         if(frame == NULL)
            return;
         packetOut = frame->packet;
         memset(packetOut, 0, 512);
         memcpy(packetOut, dhcpDiscover, sizeof(dhcpDiscover));
         memcpy(packetOut+ETHERNET_SOURCE, ethernetAddressPlasma, 6);
         memcpy(packetOut+DHCP_CLIENT_ETHERNET, ethernetAddressPlasma, 6);
         memcpy(packetOut+DHCP_MAGIC_COOKIE, dhcpOptions, sizeof(dhcpOptions));
         memcpy(packetOut+DHCP_MAGIC_COOKIE+10, ethernetAddressPlasma, 6);
         request = DHCP_REQUEST;
         packetOut[DHCP_MAGIC_COOKIE+6] = DHCP_REQUEST;
         ptr = packetOut+DHCP_MAGIC_COOKIE+sizeof(dhcpOptions)-1;
         ptr[0] = DHCP_REQUEST_IP;
         ptr[1] = 4;
         memcpy(ptr+2, packet+DHCP_YOUR_IP, 4);
         ptr[6] = DHCP_REQUEST_SERV_IP;
         ptr[7] = 4;
         memcpy(ptr+8, packet+DHCP_SERVER_IP, 4);
         ptr[12] = DHCP_END_OPTION;
         IPSendPacket(NULL, frame, 400);
      }
      else if(packet[DHCP_MAGIC_COOKIE+6] == DHCP_ACK && request == DHCP_REQUEST)
      {
         //Process DHCP Ack
         request = 0;
         DhcpRetrySeconds = 3600*4;
         memcpy(ipAddressPlasma, packet+DHCP_YOUR_IP, 4);
         printf("IP=%d.%d.%d.%d ", ipAddressPlasma[0], ipAddressPlasma[1],
            ipAddressPlasma[2], ipAddressPlasma[3]);
         memcpy(ipAddressGateway, packet+DHCP_GATEWAY_IP, 4);
         if(ipAddressGateway[0] == 0 && ipAddressGateway[1] == 0 &&
            ipAddressGateway[2] == 0 && ipAddressGateway[3] == 0)
            memcpy(ipAddressGateway, packet+DHCP_SERVER_IP, 4);
         printf("GW=%d.%d.%d.%d ", ipAddressGateway[0], ipAddressGateway[1],
            ipAddressGateway[2], ipAddressGateway[3]);
         memcpy(ethernetAddressGateway, packet+ETHERNET_SOURCE, 6);
         ptr2 = packet+DHCP_MAGIC_COOKIE+4;
         while(ptr2[0] != DHCP_END_OPTION && (int)(ptr2 - packet) < length)
         {
            if(ptr2[0] == DHCP_PARAM_DNS)
            {
               ipAddressDns = (ptr2[2] << 24) | (ptr2[3] << 16) | (ptr2[4] << 8) | ptr2[5];
               printf("DNS=%d.%d.%d.%d ", ptr2[2], ptr2[3], ptr2[4], ptr2[5]);
            }
            ptr2 += ptr2[1] + 2;
         }

         //Check if DHCP reply came from gateway
         if(memcmp(packet+IP_SOURCE, ipAddressGateway, 4))
         {
            memset(ethernetAddressGateway, 0xff, 6);
            IPArp(ipAddressGateway);     //Send ARP to gateway
         }
      }
   }
}


uint32 IPAddressSelf(void)
{
   return (ipAddressPlasma[0] << 24) | (ipAddressPlasma[1] << 16) |
          (ipAddressPlasma[2] << 8) | ipAddressPlasma[3];
}


static int IPProcessTCPPacket(IPFrame *frameIn)
{
   uint32 seq, ack;
   int length, ip_length, bytes, rc=0, notify=0, window, show;
   IPSocket *socket, *socketNew;
   IPFrame *frameOut, *frame2, *framePrev;
   uint8 *packet, *packetOut;

#if 0
   //Test missing packets
   extern void __stdcall Sleep(unsigned long value);
   Sleep(1);
   if(rand() % 13 == 0)
      return 0;
#endif

   packet = frameIn->packet;
   length = frameIn->length;

   ip_length = (packet[IP_LENGTH] << 8) | packet[IP_LENGTH+1];
   seq = (packet[TCP_SEQ] << 24) | (packet[TCP_SEQ+1] << 16) | 
         (packet[TCP_SEQ+2] << 8) | packet[TCP_SEQ+3];
   ack = (packet[TCP_ACK] << 24) | (packet[TCP_ACK+1] << 16) | 
         (packet[TCP_ACK+2] << 8) | packet[TCP_ACK+3];

   //Check if start of connection
   if((packet[TCP_FLAGS] & (TCP_FLAGS_SYN | TCP_FLAGS_ACK)) == TCP_FLAGS_SYN)
   {
      if(IPVerbose)
         printf("S");
      //Check if duplicate SYN
      for(socket = SocketHead; socket; socket = socket->next)
      {
         if(socket->state != IP_LISTEN &&
            packet[IP_PROTOCOL] == socket->headerRcv[IP_PROTOCOL] &&
            memcmp(packet+IP_SOURCE, socket->headerRcv+IP_SOURCE, 8) == 0 &&
            memcmp(packet+TCP_SOURCE_PORT, socket->headerRcv+TCP_SOURCE_PORT, 4) == 0)
         {
            if(IPVerbose)
               printf("s");
            return 0;
         }
      }

      //Find an open port
      for(socket = SocketHead; socket; socket = socket->next)
      {
         if(socket->state == IP_LISTEN &&
            packet[IP_PROTOCOL] == socket->headerRcv[IP_PROTOCOL] &&
            memcmp(packet+TCP_DEST_PORT, socket->headerRcv+TCP_DEST_PORT, 2) == 0)
         {
            //Create a new socket
            frameOut = IPFrameGet(FRAME_COUNT_SYNC);
            if(frameOut == NULL)
               return 0;
            socketNew = (IPSocket*)malloc(sizeof(IPSocket));
            if(socketNew == NULL)
               return 0;
            memcpy(socketNew, socket, sizeof(IPSocket));
            socketNew->state = IP_TCP;
            socketNew->timeout = SOCKET_TIMEOUT;
            socketNew->timeoutReset = SOCKET_TIMEOUT * 6;
            socketNew->ack = seq;
            socketNew->ackProcessed = seq + 1;
            socketNew->seq = socketNew->ack + 0x12345678;
            socketNew->seqReceived = socketNew->seq;
            socketNew->seqWindow = (packet[TCP_WINDOW_SIZE] << 8) | packet[TCP_WINDOW_SIZE+1];

            //Send ACK
            packetOut = frameOut->packet;
            EthernetCreateResponse(packetOut, packet, length);
            memcpy(socketNew->headerRcv, packet, TCP_SEQ);
            memcpy(socketNew->headerSend, packetOut, TCP_SEQ);
            packetOut[TCP_FLAGS] = TCP_FLAGS_SYN | TCP_FLAGS_ACK;
            ++socketNew->ack;
            packetOut[TCP_DATA] = 2;    //maximum segment size = 536
            packetOut[TCP_DATA+1] = 4;
            packetOut[TCP_DATA+2] = 2;
            packetOut[TCP_DATA+3] = 24;
            TCPSendPacket(socketNew, frameOut, TCP_DATA+4);
            ++socketNew->seq;

            //Add socket to linked list
            OS_MutexPend(IPMutex);
            socketNew->next = SocketHead;
            socketNew->prev = NULL;
            if(SocketHead)
               SocketHead->prev = socketNew;
            SocketHead = socketNew;
            OS_MutexPost(IPMutex);
            if(socketNew->funcPtr)
               OS_Job((JobFunc_t)socketNew->funcPtr, socketNew, 0, 0);
            return 0;
         }
      }

      //Send reset
      frameOut = IPFrameGet(0);
      if(frameOut == NULL)
         return 0;
      packetOut = frameOut->packet;
      EthernetCreateResponse(packetOut, packet, TCP_DATA);
      memset(packetOut+TCP_SEQ, 0, 4);
      ++seq;
      packetOut[TCP_ACK]   = (uint8)(seq >> 24);
      packetOut[TCP_ACK+1] = (uint8)(seq >> 16);
      packetOut[TCP_ACK+2] = (uint8)(seq >> 8);
      packetOut[TCP_ACK+3] = (uint8)seq;
      packetOut[TCP_HEADER_LENGTH] = 0x50;
      packetOut[TCP_FLAGS] = TCP_FLAGS_RST;
      IPSendPacket(NULL, frameOut, TCP_DATA);
      return 0;
   }

   //Find an open socket
   for(socket = SocketHead; socket; socket = socket->next)
   {
      if(packet[IP_PROTOCOL] == socket->headerRcv[IP_PROTOCOL] &&
         memcmp(packet+IP_SOURCE, socket->headerRcv+IP_SOURCE, 8) == 0 &&
         memcmp(packet+TCP_SOURCE_PORT, socket->headerRcv+TCP_SOURCE_PORT, 4) == 0)
      {
         break;
      }
   }
   if(socket == NULL)
   {
      return 0;
   }

   //Determine window
   socket->seqWindow = (packet[TCP_WINDOW_SIZE] << 8) | packet[TCP_WINDOW_SIZE+1];
   bytes = ip_length - (TCP_DATA - IP_VERSION_LENGTH);

   //Check if packets can be removed from retransmition list
   if(packet[TCP_FLAGS] & TCP_FLAGS_ACK)
   {
      if(ack != socket->seqReceived)
      {
         OS_MutexPend(IPMutex);
         for(frame2 = FrameResendHead; frame2; )
         {
            framePrev = frame2;
            frame2 = frame2->next;
            if(framePrev->socket == socket && (int)(ack - framePrev->seqEnd) >= 0)
            {
               //Remove packet from retransmition queue
               if(socket->timeout)
                  socket->timeout = socket->timeoutReset;
               FrameRemove(&FrameResendHead, &FrameResendTail, framePrev);
               FrameFree(framePrev);
            }
         }
         OS_MutexPost(IPMutex);
         socket->seqReceived = ack;
         socket->resentDone = 0;
      }
      else if(ack == socket->seqReceived && bytes == 0 &&
         (packet[TCP_FLAGS] & (TCP_FLAGS_RST | TCP_FLAGS_FIN)) == 0)
      {
         //Detected that packet was lost, resend
         show = 1;
         OS_MutexPend(IPMutex);
         for(frame2 = FrameResendTail; frame2; )
         {
            framePrev = frame2->prev;
            if(frame2->socket == socket)
            {
               if(frame2->retryCnt > 2)
                  break;
               if(IPVerbose && show)
                  printf("R");
               show = 0;
               //Remove packet from retransmition queue
               FrameRemove(&FrameResendHead, &FrameResendTail, frame2);
               IPSendFrame(frame2);
               //break;
            }
            frame2 = framePrev;
         }
         OS_MutexPost(IPMutex);
      }
   }

   //Check if SYN/ACK
   if((packet[TCP_FLAGS] & (TCP_FLAGS_SYN | TCP_FLAGS_ACK)) == 
      (TCP_FLAGS_SYN | TCP_FLAGS_ACK))
   {
      //Ack SYN/ACK
      socket->ack = seq + 1;
      socket->ackProcessed = seq + 1;
      frameOut = IPFrameGet(FRAME_COUNT_SEND);
      if(frameOut)
      {
         frameOut->packet[TCP_FLAGS] = TCP_FLAGS_ACK;
         TCPSendPacket(socket, frameOut, TCP_DATA);
      }
      if(socket->funcPtr)
         OS_Job((JobFunc_t)socket->funcPtr, socket, 0, 0);
      return 0;
   }
   if(packet[TCP_HEADER_LENGTH] != 0x50)
   {
      if(IPVerbose)
         printf("length error\n");
      return 0;
   }

   if(frameIn->length > ip_length + IP_VERSION_LENGTH)
      frameIn->length = (uint16)(ip_length + IP_VERSION_LENGTH);

   //Check if RST flag set
   if(packet[TCP_FLAGS] & TCP_FLAGS_RST)
   {
      notify = 1;
      IPClose2(socket);
   }
   //Copy packet into socket
   else if(socket->ack == seq && bytes > 0)
   {
      //Insert packet into socket linked list
      notify = 1;
      if(socket->timeout)
         socket->timeout = socket->timeoutReset;
      if(IPVerbose)
         printf("D");
      for(;;)
      {
         FrameInsert(&socket->frameReadHead, &socket->frameReadTail, frameIn);
         socket->ack += bytes;

         //Check if any frameFuture packets match the seq
         for(;;)
         {
            frame2 = socket->frameFutureTail;
            if(frame2 == NULL)
               break;
            packet = frame2->packet;
            seq = (packet[TCP_SEQ] << 24) | (packet[TCP_SEQ+1] << 16) | 
                  (packet[TCP_SEQ+2] << 8) | packet[TCP_SEQ+3];
            if(socket->ack > seq)
            {
               FrameRemove(&socket->frameFutureHead, &socket->frameFutureTail, frame2);
               FrameFree(frame2);
            }
            else if(socket->ack == seq)
            {
               FrameRemove(&socket->frameFutureHead, &socket->frameFutureTail, frame2);
               break;
            }
            else
            {
               frame2 = NULL;
               break;
            }
         }
         if(frame2 == NULL)
            break;
         ip_length = (packet[IP_LENGTH] << 8) | packet[IP_LENGTH+1];
         bytes = ip_length - (TCP_DATA - IP_VERSION_LENGTH);
         frameIn = frame2;
         if(IPVerbose)
            printf("d");
      }

      //Ack data
      window = RECEIVE_WINDOW - (socket->ack - socket->ackProcessed);
      frameOut = IPFrameGet(FRAME_COUNT_SEND);
      if(frameOut)
      {
         frameOut->packet[TCP_FLAGS] = TCP_FLAGS_ACK;
         TCPSendPacket(socket, frameOut, TCP_DATA);
      }

      //Using frame
      rc = 1;
   }
   else if(bytes)
   {
      if(socket->ack < seq && seq <= socket->ack + 65536)
      {
         //Save frame to frameFuture
         FrameInsert(&socket->frameFutureHead, &socket->frameFutureTail, frameIn);
         rc = 1;  //using frame
      }

      //Ack with current offset since data missing
      frameOut = IPFrameGet(FRAME_COUNT_SEND);
      if(frameOut)
      {
         frameOut->packet[TCP_FLAGS] = TCP_FLAGS_ACK;
         TCPSendPacket(socket, frameOut, TCP_DATA);
      }
   }

   //Check if FIN flag set
   if((packet[TCP_FLAGS] & TCP_FLAGS_FIN) && socket->ack >= seq &&
      socket->state < IP_CLOSED)
   {
      notify = 1;
      socket->timeout = SOCKET_TIMEOUT;
      if(IPVerbose)
         printf("F");
      frameOut = IPFrameGet(0);
      if(frameOut == NULL)
         return 0;
      packetOut = frameOut->packet;
      packetOut[TCP_FLAGS] = TCP_FLAGS_ACK;
      ++socket->ack;
      TCPSendPacket(socket, frameOut, TCP_DATA);
      if(socket->state == IP_FIN_SERVER)
         IPClose2(socket);
      else if(socket->state == IP_TCP)
         socket->state = IP_FIN_CLIENT;
   }

   //Notify application
   if(socket->funcPtr && notify)
      OS_Job((JobFunc_t)socket->funcPtr, socket, 0, 0);
   return rc;
}


int IPProcessEthernetPacket(IPFrame *frameIn, int length)
{
   int ip_length, rc;
   IPSocket *socket;
   IPFrame *frameOut;
   uint8 *packet, *packetOut;

   packet = frameIn->packet;
   frameIn->length = (uint16)length;

   if(packet[ETHERNET_FRAME_TYPE] != 0x08 || frameIn->length > PACKET_SIZE)
      return 0;  //wrong ethernet type, packet not used

   //ARP?
   if(packet[ETHERNET_FRAME_TYPE+1] == 0x06)
   {
      //Check if ARP reply
      if(memcmp(packet+ETHERNET_DEST, ethernetAddressPlasma, 6) == 0 &&
         packet[ARP_OP+1] == 2)
      {
         memcpy(ArpCache[ArpCacheIndex].ip, packet+ARP_IP_SENDER, 4);
         memcpy(ArpCache[ArpCacheIndex].mac, packet+ARP_ETHERNET_SENDER, 6);
         if(++ArpCacheIndex >= sizeof(ArpCache) / sizeof(ArpCache_t))
            ArpCacheIndex = 0;
         if(memcmp(packet+ARP_IP_SENDER, ipAddressGateway, 4) == 0)
         {
            //Found MAC address for gateway
            memcpy(ethernetAddressGateway, packet+ARP_ETHERNET_SENDER, 6);
         }
         return 0;
      }

      //Check if ARP request
      if(packet[ARP_OP] != 0 || packet[ARP_OP+1] != 1 ||  
         memcmp(packet+ARP_IP_TARGET, ipAddressPlasma, 4))
         return 0;
      //Create ARP response
      frameOut = IPFrameGet(0);
      if(frameOut == NULL)
         return 0;
      packetOut = frameOut->packet;
      memcpy(packetOut, packet, frameIn->length);
      memcpy(packetOut+ETHERNET_DEST, packet+ETHERNET_SOURCE, 6);
      memcpy(packetOut+ETHERNET_SOURCE, ethernetAddressPlasma, 6);
      packetOut[ARP_OP+1] = 2; //ARP reply
      memcpy(packetOut+ARP_ETHERNET_SENDER, ethernetAddressPlasma, 6);
      memcpy(packetOut+ARP_IP_SENDER, packet+ARP_IP_TARGET, 4);
      memcpy(packetOut+ARP_ETHERNET_TARGET, packet+ARP_ETHERNET_SENDER, 6);
      memcpy(packetOut+ARP_IP_TARGET, packet+ARP_IP_SENDER, 4);
      IPSendPacket(NULL, frameOut, frameIn->length);
      return 0;
   }

   //Check if proper type of packet
   ip_length = (packet[IP_LENGTH] << 8) | packet[IP_LENGTH+1];
   if(frameIn->length < UDP_DATA || ip_length > frameIn->length - IP_VERSION_LENGTH)
      return 0;
   if(packet[ETHERNET_FRAME_TYPE+1] != 0x00 ||
      packet[IP_VERSION_LENGTH] != 0x45)
      return 0;

   //Check if DHCP reply
   if(packet[IP_PROTOCOL] == 0x11 &&
      packet[UDP_SOURCE_PORT] == 0 && packet[UDP_SOURCE_PORT+1] == 67 &&
      packet[UDP_DEST_PORT] == 0 && packet[UDP_DEST_PORT+1] == 68)
   {
      IPDhcp(packet, frameIn->length, 2);            //DHCP reply
      return 0;
   }

   //Check if correct destination address
   if(memcmp(packet+ETHERNET_DEST, ethernetAddressPlasma, 6) ||
      memcmp(packet+IP_DEST, ipAddressPlasma, 4))
      return 0;
   rc = EthernetVerifyChecksums(packet, frameIn->length);
#ifndef WIN32
   if(rc && FrameSendFunc)
   {
      printf("C ");
      return 0;
   }
#endif

   //PING request?
   if(packet[IP_PROTOCOL] == 1)
   {
      if(packet[PING_TYPE] == 0)  //PING reply
      {
         for(socket = SocketHead; socket; socket = socket->next)
         {
            if(socket->state == IP_PING && 
               memcmp(packet+IP_SOURCE, socket->headerSend+IP_DEST, 4) == 0)
            {
               OS_Job((JobFunc_t)socket->funcPtr, socket, 0, 0);
               return 0;
            }
         }
      }
      if(packet[PING_TYPE] != 8)
         return 0;
      frameOut = IPFrameGet(FRAME_COUNT_SEND);
      if(frameOut == NULL)
         return 0;
      packetOut = frameOut->packet;
      EthernetCreateResponse(packetOut, packet, frameIn->length);
      frameOut->packet[PING_TYPE] = 0;       //PING reply
      IPSendPacket(NULL, frameOut, frameIn->length);
      return 0;
   }

   //TCP packet?
   if(packet[IP_PROTOCOL] == 0x06)
   {
      return IPProcessTCPPacket(frameIn);
   }

   //UDP packet?
   if(packet[IP_PROTOCOL] == 0x11)
   {
      //Find open socket
      for(socket = SocketHead; socket; socket = socket->next)
      {
         if(packet[IP_PROTOCOL] == socket->headerRcv[IP_PROTOCOL] &&
            memcmp(packet+IP_SOURCE, socket->headerRcv+IP_SOURCE, 8) == 0 &&
            memcmp(packet+UDP_SOURCE_PORT, socket->headerRcv+UDP_SOURCE_PORT, 2) == 0)
         {
            break;
         }
      }

      if(socket == NULL)
      {
         //Find listening socket
         for(socket = SocketHead; socket; socket = socket->next)
         {
            if(packet[IP_PROTOCOL] == socket->headerRcv[IP_PROTOCOL] &&
               memcmp(packet+UDP_DEST_PORT, socket->headerRcv+UDP_DEST_PORT, 2) == 0)
            {
               EthernetCreateResponse(socket->headerSend, packet, UDP_DATA);
               break;
            }
         }
      }

      if(socket)
      {
         if(IPVerbose)
            printf("U");
         FrameInsert(&socket->frameReadHead, &socket->frameReadTail, frameIn);
         OS_Job((JobFunc_t)socket->funcPtr, socket, 0, 0);
         return 1;
      }
   }
   return 0;
}


#ifndef WIN32
static void IPMainThread(void *arg)
{
   uint32 message[4];
   int rc;
   IPFrame *frame, *frameOut=NULL;
   uint32 ticks, ticksLast;
   (void)arg;

   ticksLast = OS_ThreadTime();
   memset(message, 0, sizeof(message));

   for(;;)
   {
      Led(7, 0);
      rc = OS_MQueueGet(IPMQueue, message, 10);
      if(rc == 0)
      {
         frame = (IPFrame*)message[1];
         if(message[0] == 0)       //frame received
         {
            Led(7, 1);
            frame->length = (uint16)message[2];
            rc = IPProcessEthernetPacket(frame, frame->length);
            if(rc == 0)
               FrameFree(frame);
         }
         else if(message[0] == 1)  //frame sent
         {
            Led(7, 2);
            assert(frame == frameOut);
            IPFrameReschedule(frame);
            frameOut = NULL;
         }
         else if(message[0] == 2)  //frame ready to send
         {
         }
      }

      if(frameOut == NULL)
      {
         OS_MutexPend(IPMutex);
         frameOut = FrameSendTail;
         if(frameOut)
            FrameRemove(&FrameSendHead, &FrameSendTail, frameOut);
         OS_MutexPost(IPMutex);
         if(frameOut)
         {
            Led(7, 4);
            UartPacketSend(frameOut->packet, frameOut->length);
         }
      }

      ticks = OS_ThreadTime();
      if(ticks - ticksLast > 100)
      {
         IPTick();
         ticksLast = ticks;
      }
   }
}
#endif


uint8 *MyPacketGet(void)
{
   return (uint8*)IPFrameGet(FRAME_COUNT_RCV);
}


//Set FrameSendFunction only if single threaded
void IPInit(IPSendFuncPtr frameSendFunction, uint8 macAddress[6], char name[6])
{
   int i;
   IPFrame *frame;

   if(macAddress)
      memcpy(ethernetAddressPlasma, macAddress, 6);
   if(name)
      memcpy(dhcpOptions+18, name, 6);
   FrameSendFunc = frameSendFunction;
   IPMutex = OS_MutexCreate("IPSem");
   IPMQueue = OS_MQueueCreate("IPMQ", FRAME_COUNT*2, 32);
   frame = (IPFrame*)malloc(sizeof(IPFrame) * FRAME_COUNT);
   if(frame == NULL)
      return;
   memset(frame, 0, sizeof(IPFrame) * FRAME_COUNT);
   for(i = 0; i < FRAME_COUNT; ++i)
   {
      frame->next = FrameFreeHead;
      frame->prev = NULL;
      FrameFreeHead = frame;
      ++frame;
   }
   FrameFreeCount = FRAME_COUNT;
#ifndef WIN32
   UartPacketConfig(MyPacketGet, PACKET_SIZE, IPMQueue);
   if(frameSendFunction == NULL)
      IPThread = OS_ThreadCreate("TCP/IP", IPMainThread, NULL, 240, 6000);
#endif
   IPDhcp(NULL, 360, 1);        //Send DHCP request
}


//To open a socket for listen set ipAddress to 0
IPSocket *IPOpen(IPMode_e mode, uint32 ipAddress, uint32 port, IPSockFuncPtr funcPtr)
{
   IPSocket *socket;
   uint8 *ptrSend, *ptrRcv;
   IPFrame *frame;
   static int portSource=0x1007;

   socket = (IPSocket*)malloc(sizeof(IPSocket));
   if(socket == NULL)
      return socket;
   memset(socket, 0, sizeof(IPSocket));
   socket->prev = NULL;
   socket->state = IP_LISTEN;
   socket->timeout = 0;
   socket->timeoutReset = SOCKET_TIMEOUT;
   socket->frameReadHead = NULL;
   socket->frameReadTail = NULL;
   socket->frameFutureHead = NULL;
   socket->frameFutureTail = NULL;
   socket->readOffset = 0;
   socket->funcPtr = funcPtr;
   socket->userData = 0;
   socket->userFunc = NULL;
   socket->userPtr = NULL;
   socket->seqWindow = 2048;
   ptrSend = socket->headerSend;
   ptrRcv = socket->headerRcv;

   if(ipAddress == 0)
   {
      //Setup listing port
      socket->headerRcv[TCP_DEST_PORT] = (uint8)(port >> 8);
      socket->headerRcv[TCP_DEST_PORT+1] = (uint8)port;
   }
   else
   {
      //Setup sending packet
      memset(ptrSend, 0, UDP_LENGTH);
      memset(ptrRcv, 0, UDP_LENGTH);

      //Setup Ethernet
      if(ipAddress != IPAddressSelf())
         memcpy(ptrSend+ETHERNET_DEST, ethernetAddressGateway, 6);
      else
         memcpy(ptrSend+ETHERNET_DEST, ethernetAddressPlasma, 6);
      memcpy(ptrSend+ETHERNET_SOURCE, ethernetAddressPlasma, 6);
      ptrSend[ETHERNET_FRAME_TYPE] = 0x08;

      //Setup IP
      ptrSend[IP_VERSION_LENGTH] = 0x45;
      ptrSend[IP_TIME_TO_LIVE] = 0x80;

      //Setup IP addresses
      memcpy(ptrSend+IP_SOURCE, ipAddressPlasma, 4);
      ptrSend[IP_DEST] = (uint8)(ipAddress >> 24);
      ptrSend[IP_DEST+1] = (uint8)(ipAddress >> 16);
      ptrSend[IP_DEST+2] = (uint8)(ipAddress >> 8);
      ptrSend[IP_DEST+3] = (uint8)ipAddress;
      ptrRcv[IP_SOURCE] = (uint8)(ipAddress >> 24);
      ptrRcv[IP_SOURCE+1] = (uint8)(ipAddress >> 16);
      ptrRcv[IP_SOURCE+2] = (uint8)(ipAddress >> 8);
      ptrRcv[IP_SOURCE+3] = (uint8)ipAddress;
      memcpy(ptrRcv+IP_DEST, ipAddressPlasma, 4);

      //Setup ports
      ptrSend[TCP_SOURCE_PORT] = (uint8)(portSource >> 8);
      ptrSend[TCP_SOURCE_PORT+1] = (uint8)portSource;
      ptrSend[TCP_DEST_PORT] = (uint8)(port >> 8);
      ptrSend[TCP_DEST_PORT+1] = (uint8)port;
      ptrRcv[TCP_SOURCE_PORT] = (uint8)(port >> 8);
      ptrRcv[TCP_SOURCE_PORT+1] = (uint8)port;
      ptrRcv[TCP_DEST_PORT] = (uint8)(portSource >> 8);
      ptrRcv[TCP_DEST_PORT+1] = (uint8)portSource;
      ++portSource;
   }

   if(mode == IP_MODE_TCP)
   {
      if(ipAddress)
         socket->state = IP_TCP;
      else
         socket->state = IP_LISTEN;
      ptrSend[IP_PROTOCOL] = 0x06;  //TCP
      ptrRcv[IP_PROTOCOL] = 0x06;
   }
   else if(mode == IP_MODE_UDP)
   {
      socket->state = IP_UDP;
      ptrSend[IP_PROTOCOL] = 0x11;  //UDP
      ptrRcv[IP_PROTOCOL] = 0x11; 
   }
   else if(mode == IP_MODE_PING)
   {
      socket->state = IP_PING;
      ptrSend[IP_PROTOCOL] = 0x01;  //PING
      memset(ptrSend+PING_TYPE, 0, 8);
      ptrSend[PING_TYPE] = 8;       //SEND
   }

   //Add socket to linked list
   OS_MutexPend(IPMutex);
   socket->next = SocketHead;
   socket->prev = NULL;
   if(SocketHead)
      SocketHead->prev = socket;
   SocketHead = socket;
   OS_MutexPost(IPMutex);

   if(mode == IP_MODE_TCP && ipAddress)
   {
      //Send TCP SYN
      socket->seq = 0x01234567;
      frame = IPFrameGet(0);
      if(frame)
      {
         frame->packet[TCP_FLAGS] = TCP_FLAGS_SYN;
         frame->packet[TCP_DATA] = 2;    //maximum segment size = 536
         frame->packet[TCP_DATA+1] = 4;
         frame->packet[TCP_DATA+2] = 2;
         frame->packet[TCP_DATA+3] = 24;
         TCPSendPacket(socket, frame, TCP_DATA+4);
         ++socket->seq;
      }
   }
   return socket;
}


void IPWriteFlush(IPSocket *socket)
{
   uint8 *packetOut;

   if(socket == NULL)
      socket = (IPSocket*)OS_ThreadInfoGet(OS_ThreadSelf(), 0);
   if(socket->frameSend && socket->state != IP_UDP &&
      socket->state != IP_PING)
   {
      packetOut = socket->frameSend->packet;
      packetOut[TCP_FLAGS] = TCP_FLAGS_ACK | TCP_FLAGS_PSH;
      TCPSendPacket(socket, socket->frameSend, TCP_DATA + socket->sendOffset);
      socket->seq += socket->sendOffset;
      socket->frameSend = NULL;
      socket->sendOffset = 0;
   }
}


uint32 IPWrite(IPSocket *socket, const uint8 *buf, uint32 length)
{
   IPFrame *frameOut;
   uint8 *packetOut;
   uint32 bytes, count=0, tries=0;
   int offset;
   OS_Thread_t *self;

   if(socket == NULL)
      socket = (IPSocket*)OS_ThreadInfoGet(OS_ThreadSelf(), 0);

   if(socket->state > IP_TCP)
      return 0;

   if(socket->timeout)
      socket->timeout = socket->timeoutReset;

#ifndef EXCLUDE_FILESYS
   if(socket->fileOut)   //override stdout
      return fwrite((char*)buf, 1, length, (FILE*)socket->fileOut);
#endif
 
   //printf("IPWrite(0x%x, %d)", Socket, Length);
   self = OS_ThreadSelf();
   while(length)
   {
      //Rate limit output
      if(socket->seq - socket->seqReceived >= SEND_WINDOW)
      {
         //printf("l(%d,%d,%d) ", socket->seq - socket->seqReceived, socket->seq, socket->seqReceived);
         if(self != IPThread && ++tries < 20)
         {
            OS_ThreadSleep(10);
            continue;
         }
      }
      tries = 0;
      while(socket->frameSend == NULL)
      {
         socket->frameSend = IPFrameGet(FRAME_COUNT_SEND);
         socket->sendOffset = 0;
         if(socket->frameSend == NULL)
         {
            //printf("L");
            if(self == IPThread || ++tries > 40)
               break;
            else
               OS_ThreadSleep(10);
         }
      }
      frameOut = socket->frameSend;
      offset = socket->sendOffset;
      if(frameOut == NULL)
      {
         printf("X");
         break;
      }
      packetOut = frameOut->packet;

      if(socket->state == IP_PING)
      {
         bytes = length;
         memcpy(packetOut, socket->headerSend, PING_DATA);
         memcpy(packetOut+PING_DATA, buf, bytes);
         IPSendPacket(socket, socket->frameSend, PING_DATA + bytes);
         socket->frameSend = NULL;
      }
      else if(socket->state != IP_UDP)
      {
         bytes = 512 - offset;
         if(bytes > length)
            bytes = length;
         socket->sendOffset += bytes;
         memcpy(packetOut+TCP_DATA+offset, buf, bytes);
         if(socket->sendOffset >= 512)
            IPWriteFlush(socket);
         //if(Socket->seq - Socket->seqReceived > Socket->seqWindow)
         //{
         //   printf("W");
         //   OS_ThreadSleep(10);
         //}
      }
      else  //UDP
      {
         bytes = length;
         memcpy(packetOut+UDP_DATA+offset, buf, bytes);
         memcpy(packetOut, socket->headerSend, UDP_LENGTH);
         IPSendPacket(socket, socket->frameSend, UDP_DATA + bytes);
         socket->frameSend = NULL;
      }
      count += bytes;
      buf += bytes;
      length -= bytes;
   }
   return count;
}


uint32 IPRead(IPSocket *socket, uint8 *buf, uint32 length)
{
   IPFrame *frame, *frame2;
   int count=0, bytes, offset;

   if(socket == NULL)
      socket = (IPSocket*)OS_ThreadInfoGet(OS_ThreadSelf(), 0);

#ifndef EXCLUDE_FILESYS
   if(socket->fileIn)   //override stdin
   {
      bytes = fread(buf, 1, 1, (FILE*)socket->fileIn);
      if(bytes == 0)
      {
         buf[0] = 0;
         fclose((FILE*)socket->fileIn);
         socket->fileIn = NULL;
         bytes = 1;
      }
      return bytes;
   }
#endif

   if(socket->state == IP_UDP)
      offset = UDP_DATA;
   else
      offset = TCP_DATA;

   OS_MutexPend(IPMutex);
   for(frame = socket->frameReadTail; length && frame; )
   {
      bytes = frame->length - offset - socket->readOffset;
      if(bytes > (int)length)
         bytes = length;
      memcpy(buf, frame->packet + offset + socket->readOffset, bytes);
      buf += bytes;
      socket->readOffset += bytes;
      length -= bytes;
      count += bytes;

      //Check if done with packet
      frame2 = frame;
      frame = frame->prev;
      if(socket->readOffset == frame2->length - offset)
      {
         //Remove packet from socket linked list
         socket->readOffset = 0;
         FrameRemove(&socket->frameReadHead, &socket->frameReadTail, frame2);
         socket->ackProcessed += frame2->length - offset;
         if(socket->state == IP_TCP &&
            socket->ack - socket->ackProcessed > RECEIVE_WINDOW - 2048)
         {
            //Update receive window for flow control
            frame2->packet[TCP_FLAGS] = TCP_FLAGS_ACK;
            TCPSendPacket(socket, frame2, TCP_DATA);
         }
         else
            FrameFree(frame2);
      }
   }
   OS_MutexPost(IPMutex);
   return count;
}


static void IPClose2(IPSocket *socket)
{
   IPFrame *frame, *framePrev;

   //printf("IPClose2(%x) ", (int)socket);

   OS_MutexPend(IPMutex);

   //Remove pending packets
   for(frame = FrameSendHead; frame; )
   {
      framePrev = frame;
      frame = frame->next;
      if(framePrev->socket == socket)
      {
         FrameRemove(&FrameResendHead, &FrameResendTail, framePrev);
         FrameFree(framePrev);
      }
   }

   //Remove packets from retransmision list
   for(frame = FrameResendHead; frame; )
   {
      framePrev = frame;
      frame = frame->next;
      if(framePrev->socket == socket)
      {
         FrameRemove(&FrameResendHead, &FrameResendTail, framePrev);
         FrameFree(framePrev);
      }
   }

   //Remove packets from socket read linked list
   for(frame = socket->frameReadHead; frame; )
   {
      framePrev = frame;
      frame = frame->next;
      FrameRemove(&socket->frameReadHead, &socket->frameReadTail, framePrev);
      FrameFree(framePrev);
   }

   //Remove packets from socket future linked list
   for(frame = socket->frameFutureHead; frame; )
   {
      framePrev = frame;
      frame = frame->next;
      FrameRemove(&socket->frameFutureHead, &socket->frameFutureTail, framePrev);
      FrameFree(framePrev);
   }

   //Give application time to stop using socket
   socket->timeout = SOCKET_TIMEOUT;
   socket->state = IP_CLOSED;

   OS_MutexPost(IPMutex);
}


void IPClose(IPSocket *socket)
{
   IPFrame *frameOut;

   //printf("IPClose(%x) ", (int)socket);

   IPWriteFlush(socket);
   if(socket->state <= IP_UDP)
   {
      IPClose2(socket);
      return;
   }
   frameOut = IPFrameGet(0);
   if(frameOut == NULL)
      return;
   frameOut->packet[TCP_FLAGS] = TCP_FLAGS_FIN | TCP_FLAGS_ACK;
   TCPSendPacket(socket, frameOut, TCP_DATA);
   ++socket->seq;
   socket->timeout = SOCKET_TIMEOUT;
   socket->timeoutReset = SOCKET_TIMEOUT;
   socket->state = IP_FIN_SERVER;
}


int IPPrintf(IPSocket *socket, char *format, 
              int arg0, int arg1, int arg2, int arg3,
              int arg4, int arg5, int arg6, int arg7)
{
   char buffer[256], *ptr = buffer;
   int rc = 1;
   int length;

   if(socket == NULL)
      socket = (IPSocket*)OS_ThreadInfoGet(OS_ThreadSelf(), 0);
   if(strcmp(format, "%s") == 0)
      ptr = (char*)arg0;
   else
      rc = sprintf(buffer, format, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
   length = strlen(ptr);
   IPWrite(socket, (unsigned char*)ptr, length);
   if(socket->dontFlush == 0 || (socket->dontFlush < 2 && strstr(format, "\n")))
      IPWriteFlush(socket);
   return rc;
}



void IPTick(void)
{
   IPFrame *frame, *frame2;
   IPSocket *socket, *socket2;
   unsigned long ticks;
   static unsigned long ticksPrev=0, ticksPrev2=0;

   ticks = OS_ThreadTime();
#ifdef WIN32
   ticks = ticksPrev + 100;
#endif
   if(ticks - ticksPrev >= 95)
   {
      if(IPVerbose && (Seconds % 60) == 0)
      {
         if(FrameFreeCount >= FRAME_COUNT-1)
            printf("T");
         else
            printf("T(%d)", FrameFreeCount);
      }
      ++Seconds;
      if(--DhcpRetrySeconds <= 0)
         IPDhcp(NULL, 400, 1);   //DHCP request
   }

   OS_MutexPend(IPMutex);

   //Retransmit timeout packets
   for(frame = FrameResendTail; frame; )
   {
      frame2 = frame->prev;
      frame->timeout = (short)(frame->timeout - (ticks - ticksPrev2));
      if(--frame->timeout <= 0)
      {
         if(IPVerbose)
            printf("r" /*"(%x,%x,%d,%d,%d)"*/, (int)frame, (int)frame->socket, 
               frame->retryCnt, frame->length - TCP_DATA,
               frame->socket->state);
         FrameRemove(&FrameResendHead, &FrameResendTail, frame);
         if(frame->retryCnt < 5 && frame->socket->state < IP_CLOSED)
            IPSendFrame(frame);
         else 
         {
            if(frame->socket->state == IP_TCP)
               IPClose(frame->socket);
            FrameFree(frame);
         }
      }
      frame = frame2;
   }

   if(ticks - ticksPrev >= 95)
   {
      //Close timed out sockets
      for(socket = SocketHead; socket; )
      {
         socket2 = socket;
         socket = socket->next;
         if(socket2->timeout && --socket2->timeout == 0)
         {
            socket2->timeout = SOCKET_TIMEOUT;
            if(socket2->state <= IP_TCP || socket2->state == IP_FIN_CLIENT)
               IPClose(socket2);
            else if(socket2->state != IP_CLOSED)
               IPClose2(socket2);
            else
            {
               if(socket2->prev == NULL)
                  SocketHead = socket2->next;
               else
                  socket2->prev->next = socket2->next;
               if(socket2->next)
                  socket2->next->prev = socket2->prev;
               //printf("freeSocket(%x) ", (int)socket2);
               free(socket2);
            }
         }
      }
      ticksPrev = ticks;
   }
   OS_MutexPost(IPMutex);
   ticksPrev2 = ticks;
}


static void DnsCallback(IPSocket *socket)
{
   uint8 buf[200], *ptr;
   uint32 ipAddress;
   int bytes;

   memset(buf, 0, sizeof(buf));
   bytes = IPRead(socket, buf, sizeof(buf));
   if(buf[DNS_NUM_ANSWERS_RR+1])
   {
      for(ptr = buf + DNS_QUESTIONS; ptr + 14 <= buf + bytes; ++ptr)
      {
         if(ptr[0] == 0 && ptr[1] == 1 && ptr[2] == 0 && ptr[3] == 1 && 
            ptr[8] == 0 && ptr[9] == 4)
         {
            ipAddress = (ptr[10] << 24) | (ptr[11] << 16) | (ptr[12] << 8) | ptr[13];
            printf("ipAddress = %d.%d.%d.%d\n", ptr[10], ptr[11], ptr[12], ptr[13]);
            socket->userData = ipAddress;
            if(socket->userFunc)
            {
               socket->userFunc(socket, (uint8*)socket->userPtr, ipAddress);
            }
            break;
         }
      }
   }
   IPClose(socket);
}


void IPResolve(char *name, IPCallbackPtr resolvedFunc, void *arg)
{
   uint8 buf[200], *ptr;
   int length, i;
   IPSocket *socket;

   socket = IPOpen(IP_MODE_UDP, ipAddressDns, DNS_PORT, DnsCallback);
   if(socket == NULL)
      return;
   memset(buf, 0, sizeof(buf));
   buf[DNS_ID+1] = 1;
   buf[DNS_FLAGS] = 1;
   buf[DNS_NUM_QUESTIONS+1] = 1;

   //Setup name
   ptr = buf + DNS_QUESTIONS;
   strncpy((char*)ptr+1, name, 100);
   ptr[0] = 1;
   while(ptr[0])
   {
      for(i = 0; i < 100; ++i)
      {
         if(ptr[i+1] == '.' || ptr[i+1] == 0)
         {
            ptr[0] = (uint8)i;
            ptr += i+1;
            break;
         }
      }
   }
   ++ptr;
   ptr[1] = DNS_QUERY_TYPE_IP;
   ptr[3] = DNS_QUERY_CLASS;
   length = (int)(ptr - buf) + 4;
   if(length < 60)
      length = 60;

   socket->userFunc = resolvedFunc;
   socket->userPtr = arg;
   socket->userData = 0;
   IPWrite(socket, buf, length);
}

