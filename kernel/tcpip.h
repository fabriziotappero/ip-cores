/*--------------------------------------------------------------------
 * TITLE: Plasma TCP/IP Protocol Stack
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 4/22/06
 * FILENAME: tcpip.h
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Plasma TCP/IP Protocol Stack
 *--------------------------------------------------------------------*/
#ifndef __TCPIP_H__
#define __TCPIP_H__
#define PACKET_SIZE           600
#define FRAME_COUNT           100
#define FRAME_COUNT_SYNC      15
#define FRAME_COUNT_SEND      10
#define FRAME_COUNT_RCV       5
#define RETRANSMIT_TIME       60
#define SOCKET_TIMEOUT        10
#define SEND_WINDOW           7000
#define RECEIVE_WINDOW        (536*10)

typedef enum IPMode_e {
   IP_MODE_UDP,
   IP_MODE_TCP,
   IP_MODE_PING
} IPMode_e;

typedef enum IPState_e {
   IP_LISTEN,
   IP_PING,
   IP_UDP,
   IP_SYN,
   IP_TCP,
   IP_FIN_CLIENT,
   IP_FIN_SERVER,
   IP_CLOSED
} IPState_e;

typedef struct IPSocket IPSocket;
typedef void (*IPSendFuncPtr)(uint8 *packet, int length);
typedef void (*IPSockFuncPtr)(IPSocket *sock);
typedef void (*IPCallbackPtr)(IPSocket *sock, uint8 *buf, int bytes); 

typedef struct IPFrame {
   uint8 packet[PACKET_SIZE];
   struct IPFrame *next, *prev;
   struct IPSocket *socket;
   uint32 seqEnd;
   uint16 length;
   short  timeout;
   uint8 state, retryCnt;
   uint8 pad1, pad2;
} IPFrame;

struct IPSocket {
   struct IPSocket *next, *prev;
   IPState_e state;
   uint32 seq;
   uint32 seqReceived;
   uint32 seqWindow;
   uint32 ack;
   uint32 ackProcessed;
   uint32 timeout;
   uint32 timeoutReset;
   int resentDone;
   int dontFlush;
   uint8 headerSend[38];
   uint8 headerRcv[38];
   struct IPFrame *frameReadHead;
   struct IPFrame *frameReadTail;
   struct IPFrame *frameFutureHead;
   struct IPFrame *frameFutureTail;
   int readOffset;
   struct IPFrame *frameSend;
   int sendOffset;
   void *fileOut;
   void *fileIn;
   IPSockFuncPtr funcPtr;
   IPCallbackPtr userFunc;
   void *userPtr;
   void *userPtr2;
   uint32 userData;
   uint32 userData2;
   OS_Semaphore_t *userSemaphore;
};

//ethernet.c
void EthernetSendPacket(const unsigned char *packet, int length); //Windows
void EthernetInit(unsigned char MacAddress[6]);
int EthernetReceive(unsigned char *buffer, int length);
void EthernetTransmit(unsigned char *buffer, int length);

//tcpip.c
void IPInit(IPSendFuncPtr frameSendFunction, uint8 macAddress[6], char name[6]);
IPFrame *IPFrameGet(int freeCount);
int IPProcessEthernetPacket(IPFrame *frameIn, int length);
void IPTick(void);

IPSocket *IPOpen(IPMode_e mode, uint32 ipAddress, uint32 port, IPSockFuncPtr funcPtr);
void IPWriteFlush(IPSocket *socket);
uint32 IPWrite(IPSocket *socket, const uint8 *buf, uint32 length);
uint32 IPRead(IPSocket *socket, uint8 *buf, uint32 length);
void IPClose(IPSocket *socket);
#ifdef INSIDE_TCPIP
int IPPrintf(IPSocket *socket, char *message, 
   int arg0, int arg1, int arg2, int arg3,
   int arg4, int arg5, int arg6, int arg7);
#else
int IPPrintf(IPSocket *socket, char *message, ...);
#endif
void IPResolve(char *name, IPCallbackPtr resolvedFunc, void *arg);
uint32 IPAddressSelf(void);

//http.c
#define HTML_LENGTH_CALLBACK  -2
#define HTML_LENGTH_LIST_END  -1
typedef struct PageEntry_s {
   const char *name;
   int length;
   const char *page;
} PageEntry_t;
void HttpInit(const PageEntry_t *Pages, int UseFiles);

//html.c
void HtmlInit(int UseFiles);

//netutil.c
void FtpdInit(int UseFiles);
IPSocket *FtpTransfer(uint32 ip, char *user, char *passwd, 
                      char *filename, uint8 *buf, int size, 
                      int send, IPCallbackPtr callback);
void TftpdInit(void);
IPSocket *TftpTransfer(uint32 ip, char *filename, uint8 *buffer, int size,
                       IPCallbackPtr callback);
void ConsoleInit(void);
void *IPNameValue(const char *name, void *value);
int ConsoleGetch(void);
void ConsoleRun(IPSocket *socket, char *argv[]);
#ifndef INSIDE_NETUTIL
int ConsoleScanf(char *format, ...);
int ConsolePrintf(char *format, ...);
#endif

#endif //__TCPIP_H__
