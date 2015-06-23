/*--------------------------------------------------------------------
 * TITLE: Plasma Uart Driver
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 12/31/05
 * FILENAME: uart.c
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Plasma Uart Driver
 *    UART_PACKETS permits "Ethernet" packets to be sent and received.
 *--------------------------------------------------------------------*/
#define NO_ELLIPSIS2
#include "plasma.h"
#include "rtos.h"

#define BUFFER_WRITE_SIZE 128
#define BUFFER_READ_SIZE 128
#define BUFFER_PRINTF_SIZE 1024
#undef UartPrintf

void UartPrintfCritical(const char *format,
                        int arg0, int arg1, int arg2, int arg3,
                        int arg4, int arg5, int arg6, int arg7);

typedef struct Buffer_s {
   uint8 *data;
   int size;
   volatile int read, write;
   volatile int pendingRead, pendingWrite;
   OS_Semaphore_t *semaphoreRead, *semaphoreWrite;
} Buffer_t;

static Buffer_t *WriteBuffer, *ReadBuffer;
static OS_Semaphore_t *SemaphoreUart;
static char PrintfString[BUFFER_PRINTF_SIZE];  //Used in UartPrintf

#ifdef UART_PACKETS
//For packet processing [0xff lengthMSB lengthLSB checksum data]
static PacketGetFunc_t UartPacketGet;
static uint8 *PacketCurrent;
static uint32 UartPacketSize;
static uint32 UartPacketChecksum, Checksum;
static OS_MQueue_t *UartPacketMQueue;
static uint32 PacketBytes, PacketLength;
static uint32 UartPacketOutLength, UartPacketOutByte;
int CountOk, CountError;
static uint8 *UartPacketOut;
#endif //UART_PACKETS


/******************************************/
Buffer_t *BufferCreate(int size)
{
   Buffer_t *buffer;
   buffer = (Buffer_t*)OS_HeapMalloc(NULL, sizeof(Buffer_t) + size);
   if(buffer == NULL)
      return NULL;
   buffer->data = (uint8*)(buffer + 1);
   buffer->read = 0;
   buffer->write = 0;
   buffer->size = size;
   buffer->pendingRead = 0;
   buffer->pendingWrite = 0;
   buffer->semaphoreRead = OS_SemaphoreCreate("BufferRead", 0);
   buffer->semaphoreWrite = OS_SemaphoreCreate("BufferWrite", 0);
   return buffer;
}


void BufferWrite(Buffer_t *buffer, int value, int pend)
{
   int writeNext;

   writeNext = buffer->write + 1;
   if(writeNext >= buffer->size)
      writeNext = 0;

   //Check if room for value
   if(writeNext == buffer->read)
   {
      if(pend == 0)
         return;
      ++buffer->pendingWrite;
      OS_SemaphorePend(buffer->semaphoreWrite, OS_WAIT_FOREVER);
   }

   buffer->data[buffer->write] = (uint8)value;
   buffer->write = writeNext;
   if(buffer->pendingRead)
   {
      --buffer->pendingRead;
      OS_SemaphorePost(buffer->semaphoreRead);
   }
}


int BufferRead(Buffer_t *buffer, int pend)
{
   int value;

   //Check if empty buffer
   if(buffer->read == buffer->write)
   {
      if(pend == 0)
         return 0;
      ++buffer->pendingRead;
      OS_SemaphorePend(buffer->semaphoreRead, OS_WAIT_FOREVER);
   }

   value = buffer->data[buffer->read];
   if(++buffer->read >= buffer->size)
      buffer->read = 0;
   if(buffer->pendingWrite)
   {
      --buffer->pendingWrite;
      OS_SemaphorePost(buffer->semaphoreWrite);
   }
   return value;
}


/******************************************/
#ifdef UART_PACKETS
static void UartPacketRead(uint32 value)
{
   uint32 message[4];
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
      if(PacketLength <= UartPacketSize)
      {
         if(PacketCurrent == NULL)
            PacketCurrent = UartPacketGet();
      }
      else
      {
         PacketBytes = 0;
      }
   }
   else if(PacketBytes == 3)
   {
      ++PacketBytes;
      UartPacketChecksum = value;
      Checksum = 0;
   }
   else if(PacketBytes >= 4)
   {
      if(PacketCurrent)
         PacketCurrent[PacketBytes - 4] = (uint8)value;
      Checksum += value;
      ++PacketBytes;
      if(PacketBytes - 4 >= PacketLength)
      {
         if((uint8)Checksum == UartPacketChecksum)
         {
            //Notify thread that a packet has been received
            ++CountOk;
            message[0] = 0;
            message[1] = (uint32)PacketCurrent;
            message[2] = PacketLength;
            if(PacketCurrent)
               OS_MQueueSend(UartPacketMQueue, message);
            PacketCurrent = NULL;
         }
         else
         {
            ++CountError;
            //printf("E");
         }
         PacketBytes = 0;
      }
   }
}


static int UartPacketWrite(void)
{
   int value=0, i;
   uint32 message[4];
   if(UartPacketOut)
   {
      if(UartPacketOutByte == 0)
      {
         value = 0xff;
         ++UartPacketOutByte;
      }
      else if(UartPacketOutByte == 1)
      {
         value = UartPacketOutLength >> 8;
         ++UartPacketOutByte;
      }
      else if(UartPacketOutByte == 2)
      {
         value = (uint8)UartPacketOutLength;
         ++UartPacketOutByte;
      }
      else if(UartPacketOutByte == 3)
      {
         value = 0;
         for(i = 0; i < (int)UartPacketOutLength; ++i)
            value += UartPacketOut[i];
         value = (uint8)value;
         ++UartPacketOutByte;
      }
      else 
      {
         value = UartPacketOut[UartPacketOutByte - 4];
         ++UartPacketOutByte;
         if(UartPacketOutByte - 4 >= UartPacketOutLength)
         {
            //Notify thread that a packet has been sent
            message[0] = 1;
            message[1] = (uint32)UartPacketOut;
            UartPacketOut = 0;
            OS_MQueueSend(UartPacketMQueue, message);
         }
      }
   }
   return value;
}
#endif  //UART_PACKETS


static void UartInterrupt(void *arg)
{
   uint32 status, value, count=0;
   (void)arg;

   status = OS_InterruptStatus();
   while(status & IRQ_UART_READ_AVAILABLE)
   {
      value = MemoryRead(UART_READ);
#ifdef UART_PACKETS
      if(UartPacketGet && (value == 0xff || PacketBytes))
         UartPacketRead(value);
      else
#endif
      BufferWrite(ReadBuffer, value, 0);
      status = OS_InterruptStatus();
      if(++count >= 16)
         break;
   }
   while(status & IRQ_UART_WRITE_AVAILABLE)
   {
#ifdef UART_PACKETS
      if(UartPacketOut)
      {
         value = UartPacketWrite();
         MemoryWrite(UART_WRITE, value);
      } else 
#endif
      if(WriteBuffer->read != WriteBuffer->write)
      {
         value = BufferRead(WriteBuffer, 0);
         MemoryWrite(UART_WRITE, value);
      }
      else
      {
         OS_InterruptMaskClear(IRQ_UART_WRITE_AVAILABLE);
         break;
      }
      status = OS_InterruptStatus();
   }
}


void UartInit(void)
{
   uint32 mask;

   SemaphoreUart = OS_SemaphoreCreate("Uart", 1);
   WriteBuffer = BufferCreate(BUFFER_WRITE_SIZE);
   ReadBuffer = BufferCreate(BUFFER_READ_SIZE);

   mask = IRQ_UART_READ_AVAILABLE | IRQ_UART_WRITE_AVAILABLE;
   OS_InterruptRegister(mask, UartInterrupt);
   OS_InterruptMaskSet(IRQ_UART_READ_AVAILABLE);
}


void UartWrite(int ch)
{
   BufferWrite(WriteBuffer, ch, 1);
   OS_InterruptMaskSet(IRQ_UART_WRITE_AVAILABLE);
}


uint8 UartRead(void)
{
   return (uint8)BufferRead(ReadBuffer, 1);
}


void UartWriteData(uint8 *data, int length)
{
   OS_SemaphorePend(SemaphoreUart, OS_WAIT_FOREVER);
   while(length--)
      UartWrite(*data++);
   OS_SemaphorePost(SemaphoreUart);
}


void UartReadData(uint8 *data, int length)
{
   OS_SemaphorePend(SemaphoreUart, OS_WAIT_FOREVER);
   while(length--)
      *data++ = UartRead();
   OS_SemaphorePost(SemaphoreUart);
}


void UartPrintf(const char *format,
                int arg0, int arg1, int arg2, int arg3,
                int arg4, int arg5, int arg6, int arg7)
{
   uint8 *ptr;
#if 0
   //Check for string "!m#~" to mask print statement
   static char moduleLevel[26];
   if(format[0] == '!' && format[3] == '~')
   {
      int level = format[2] - '5';
      if('a' <= format[1] && format[1] <= 'z')
      {
         if(level < moduleLevel[format[1] - 'a'])
            return;
      }
      else if('A' <= format[1] && format[1] <= 'Z')
         moduleLevel[format[1] - 'A'] = (char)level;
      format += 4;
   }
#endif
   OS_SemaphorePend(SemaphoreUart, OS_WAIT_FOREVER);
   sprintf(PrintfString, format, arg0, arg1, arg2, arg3,
           arg4, arg5, arg6, arg7);
   ptr = (uint8*)PrintfString;
   while(*ptr)
   {
      if(*ptr == '\n')
         UartWrite('\r');
#ifdef UART_PACKETS
      if(*ptr == 0xff)
         *ptr = '@';
#endif
      UartWrite(*ptr++);
   }
   OS_SemaphorePost(SemaphoreUart);
}


#if 0
void UartPrintfPoll(const char *format,
                    int arg0, int arg1, int arg2, int arg3,
                    int arg4, int arg5, int arg6, int arg7)
{
   uint8 *ptr;
   uint32 state;

   if(SemaphoreUart)
      OS_SemaphorePend(SemaphoreUart, OS_WAIT_FOREVER);
   sprintf(PrintfString, format, arg0, arg1, arg2, arg3,
           arg4, arg5, arg6, arg7);
   ptr = (uint8*)PrintfString;
   while(*ptr)
   {
      while((MemoryRead(IRQ_STATUS) & IRQ_UART_WRITE_AVAILABLE) == 0)
         ;
      state = OS_CriticalBegin();
      if((MemoryRead(IRQ_STATUS) & IRQ_UART_WRITE_AVAILABLE) &&
         UartPacketOut == NULL)
      {
         MemoryWrite(UART_WRITE, *ptr++);
      }
      OS_CriticalEnd(state);
   }
   if(SemaphoreUart)
      OS_SemaphorePost(SemaphoreUart);
}
#endif


void UartPrintfCritical(const char *format,
                        int arg0, int arg1, int arg2, int arg3,
                        int arg4, int arg5, int arg6, int arg7)
{
   char buffer[128];
   uint8 *ptr;
   uint32 state;

   state = OS_CriticalBegin();
   sprintf(buffer, format, arg0, arg1, arg2, arg3,
           arg4, arg5, arg6, arg7);
   ptr = (uint8*)buffer;
   while(*ptr)
   {
      while((MemoryRead(IRQ_STATUS) & IRQ_UART_WRITE_AVAILABLE) == 0)
         ;
      MemoryWrite(UART_WRITE, *ptr++);
#ifdef UART_PACKETS
      if(UartPacketOut && UartPacketOutByte - 4 < UartPacketOutLength)
      {
         ++UartPacketOutByte;
         --ptr;
      }
#endif
   }
   OS_CriticalEnd(state);
}


void UartScanf(const char *format,
               int arg0, int arg1, int arg2, int arg3,
               int arg4, int arg5, int arg6, int arg7)
{
   int index = 0, ch;
   OS_SemaphorePend(SemaphoreUart, OS_WAIT_FOREVER);
   for(;;)
   {
      ch = UartRead();
      if(ch != '\b' || index)
         UartWrite(ch);
      if(ch == '\n' || ch == '\r')
         break;
      else if(ch == '\b')
      {
         if(index)
         {
            UartWrite(' ');
            UartWrite(ch);
            --index;
         }
      }
      else if(index < sizeof(PrintfString))
         PrintfString[index++] = (uint8)ch;
   }
   UartWrite('\n');
   PrintfString[index] = 0;
   sscanf(PrintfString, format, arg0, arg1, arg2, arg3,
          arg4, arg5, arg6, arg7);
   OS_SemaphorePost(SemaphoreUart);
}


#ifdef UART_PACKETS
void UartPacketConfig(PacketGetFunc_t PacketGetFunc, 
                      int PacketSize, 
                      OS_MQueue_t *mQueue)
{
   UartPacketGet = PacketGetFunc;
   UartPacketSize = PacketSize;
   UartPacketMQueue = mQueue;
}


void UartPacketSend(uint8 *data, int bytes)
{
   UartPacketOutByte = 0;
   UartPacketOutLength = bytes;
   UartPacketOut = data;
   OS_InterruptMaskSet(IRQ_UART_WRITE_AVAILABLE);
}
#else  //UART_PACKETS
void UartPacketConfig(PacketGetFunc_t PacketGetFunc, 
                      int PacketSize, 
                      OS_MQueue_t *mQueue)
{ (void)PacketGetFunc; (void)PacketSize; (void)mQueue; }


void UartPacketSend(uint8 *data, int bytes)
{ (void)data; (void)bytes; }
#endif


void Led(int mask, int value)
{
   mask &= 0xff;
   MemoryWrite(GPIO0_CLEAR, mask);       //clear
   MemoryWrite(GPIO0_SET, value & mask); //set LEDs
}


/******************************************/
int OS_puts(const char *string)
{
   uint8 *ptr;
   OS_SemaphorePend(SemaphoreUart, OS_WAIT_FOREVER);
   ptr = (uint8*)string;
   while(*ptr)
   {
      if(*ptr == '\n')
         UartWrite('\r');
      UartWrite(*ptr++);
   }
   OS_SemaphorePost(SemaphoreUart);
   return 0;
}


int OS_getch(void)
{
   return BufferRead(ReadBuffer, 1);
}


int OS_kbhit(void)
{
   return ReadBuffer->read != ReadBuffer->write;
}


/******************************************/
#if 0
int LogArray[100], LogIndex;
void LogWrite(int a)
{
   if(LogIndex < sizeof(LogArray)/4)
      LogArray[LogIndex++] = a;
}

void LogDump(void)
{
   int i;
   for(i = 0; i < LogIndex; ++i)
   {
      if(LogArray[i] > 0xfff)
         UartPrintfCritical("\n", 0,0,0,0,0,0,0,0);
      UartPrintfCritical("0x%x ", LogArray[i], 0,0,0,0,0,0,0);
   }
   LogIndex = 0;
}
#endif

