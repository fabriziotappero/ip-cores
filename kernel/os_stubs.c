/*--------------------------------------------------------------------
 * TITLE: OS stubs
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 2/18/08
 * FILENAME: os_stubs.c
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *--------------------------------------------------------------------*/
#include <stdlib.h>
#include "plasma.h"
#include "rtos.h"

static unsigned char *flash;

void FlashLock(void)   {}
void FlashUnlock(void) {}

void FlashRead(uint16 *dst, uint32 byteOffset, int bytes)
{
   if(flash == NULL)
   {
      flash = (unsigned char*)malloc(1024*1024*16);
      memset(flash, 0xff, 1024*1024*16);
   }
   memcpy(dst, flash+byteOffset, bytes);
}


void FlashWrite(uint16 *src, uint32 byteOffset, int bytes)
{
   memcpy(flash+byteOffset, src, bytes);
}


void FlashErase(uint32 byteOffset)
{
   memset(flash+byteOffset, 0xff, 1024*128);
}


//Stub out RTOS functions
#undef malloc
#undef free
#undef printf
static void *infoValue;
void *OS_HeapMalloc(OS_Heap_t *heap, int bytes) {(void)heap; return malloc(bytes);}
void OS_HeapFree(void *block)                {free(block);}
void UartPrintfCritical(const char *format, 
                        int a, int b, int c, int d, int e, int f, int g, int h) 
{printf(format,a,b,c,d,e,f,g,h);}
uint32 OS_AsmInterruptEnable(uint32 state)   {(void)state; return 0;}
void OS_Assert(void)        
{}
OS_Thread_t *OS_ThreadCreate(const char *name,
                             OS_FuncPtr_t funcPtr, 
                             void *arg, 
                             uint32 priority, 
                             uint32 stackSize)
{(void)name;(void)funcPtr;(void)arg;(void)priority;(void)stackSize;return NULL;}
void OS_ThreadExit(void)                     {}
OS_Thread_t *OS_ThreadSelf(void)             {return NULL;}
void OS_ThreadSleep(int ticks)               {(void)ticks;}
uint32 OS_ThreadTime(void)                   {return 0;}
void *OS_ThreadInfoGet(OS_Thread_t *thread, uint32 index)
{(void)thread;(void)index;return infoValue;}
void OS_ThreadInfoSet(OS_Thread_t *thread, uint32 index, void *info)
{(void)thread;(void)index;infoValue=info;}

OS_Semaphore_t *OS_SemaphoreCreate(const char *name, uint32 count) 
{(void)name;(void)count;return NULL;}
void OS_SemaphoreDelete(OS_Semaphore_t *semaphore) {(void)semaphore;}
int OS_SemaphorePend(OS_Semaphore_t *semaphore, int ticks) 
{(void)semaphore; (void)ticks; return 0;}
void OS_SemaphorePost(OS_Semaphore_t *semaphore) {(void)semaphore;}

OS_Mutex_t *OS_MutexCreate(const char *name) {(void)name; return NULL;}
void OS_MutexDelete(OS_Mutex_t *semaphore)   {(void)semaphore;}
void OS_MutexPend(OS_Mutex_t *semaphore)     {(void)semaphore;}
void OS_MutexPost(OS_Mutex_t *semaphore)     {(void)semaphore;}
#if OS_CPU_COUNT > 1
   uint32 OS_SpinLock(void)                     {return 0;}
   void OS_SpinUnlock(uint32 state)             {(void)state;}
#endif

OS_MQueue_t *OS_MQueueCreate(const char *name,
                             int messageCount,
                             int messageBytes)
{(void)name;(void)messageCount;(void)messageBytes; return NULL;}
void OS_MQueueDelete(OS_MQueue_t *mQueue)    {(void)mQueue;}
int OS_MQueueSend(OS_MQueue_t *mQueue, void *message) 
{(void)mQueue;(void)message; return 0;}
int OS_MQueueGet(OS_MQueue_t *mQueue, void *message, int ticks)
{(void)mQueue;(void)message;(void)ticks; return 0;}

void OS_Job(JobFunc_t funcPtr, void *arg0, void *arg1, void *arg2)
{funcPtr(arg0, arg1, arg2);}


