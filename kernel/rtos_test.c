/*--------------------------------------------------------------------
 * TITLE: Test Plasma Real Time Operating System
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 1/1/06
 * FILENAME: rtos_test.c
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Test Plasma Real Time Operating System
 *--------------------------------------------------------------------*/
#ifdef WIN32
#include <stdlib.h>
#endif
#include "plasma.h"
#include "rtos.h"
#include "tcpip.h"

/* Including mmu.h will cause all OS calls to use SYSCALL */
//#include "mmu.h"

//#define DLL_SETUP
//#define DLL_CALL
//#include "dll.h"

#define SEMAPHORE_COUNT 50
#define TIMER_COUNT     10

extern void TestMathFull(void);

typedef struct {
   OS_Thread_t *MyThread[TIMER_COUNT];
   OS_Semaphore_t *MySemaphore[SEMAPHORE_COUNT];
   OS_Mutex_t *MyMutex;
   OS_Timer_t *MyTimer[TIMER_COUNT];
   OS_MQueue_t *MyQueue[TIMER_COUNT];
   int TimerDone;
} TestInfo_t;

int Global;

//******************************************************************
static void TestCLib(void)
{
   char s1[80], s2[80], *ptr;
   int rc, v1, v2, v3;

   printf("TestCLib\n");
   strcpy(s1, "Hello ");
   memset(s2, 0, sizeof(s2));
   strncpy(s2, "World wide", 5);
   strcat(s1, s2);
   strncat(s1, "!\nthing", 2);
   printf("%s", s1);
   rc = strcmp(s1, "Hello World!\n");
   assert(rc == 0);
   rc = strcmp(s1, "Hello WOrld!\n");
   assert(rc > 0);
   rc = strcmp(s1, "Hello world!\n");
   assert(rc < 0);
   rc = strncmp(s1, "Hellx", 4);
   assert(rc == 0);
   ptr = strstr(s1, "orl");
   assert(ptr && ptr[0] == 'o');
   rc = strlen(s1);
   assert(rc == 13);
   memcpy(s2, s1, rc+1);
   rc = memcmp(s1, s2, 8);
   assert(rc == 0);
   s2[5] = 'z';
   rc = memcmp(s1, s2, 8);
   assert(rc != 0);
   memset(s2, 0, 5);
   memset(s2, 'a', 3);
   rc = abs(-5);
   itoa(1234, s1, 10);
   itoa(0, s1, 10);
   itoa(-1234, s1, 10);
   itoa(0xabcd, s1, 16);
   itoa(0x12ab, s1, 16);
   sprintf(s1, "test c%c d%d 0x%x s%s End\n", 'C', 1234, 0xabcd, "String");
   printf("%s", s1);
   sprintf(s1, "test c%c d%6d 0x%6x s%8s End\n", 'C', 1234, 0xabcd, "String");
   printf("%s", s1);
   sscanf("1234 -1234 0xabcd text h", "%d %d %x %s", &v1, &v2, &v3, s1);
   assert(v1 == 1234 && v2 == -1234 && v3 == 0xabcd);
   assert(strcmp(s1, "text") == 0);
   //UartScanf("%d %d", &v1, &v2);
   //printf("v1 = %d v2 = %d\n", v1, v2);
   printf("Done.\n");
}

//******************************************************************
static void TestHeap(void)
{
   uint8 *ptrs[256], size[256], *ptr;
   int i, j, k, value;

   printf("TestHeap\n");
   memset(ptrs, 0, sizeof(ptrs));
   memset(size, 0, sizeof(size));
   for(i = 0; i < 1000; ++i)
   {
      j = rand() & 255;
      if(ptrs[j])
      {
         ptr = ptrs[j];
         value = size[j];
         for(k = 0; k < value; ++k)
         {
            if(ptr[k] != value)
            {
               printf("Error\n");
               break;
            }
         }
         OS_HeapFree(ptrs[j]);
      }
      size[j] = (uint8)(rand() & 255);
      ptrs[j] = (uint8*)OS_HeapMalloc(NULL, size[j]);
      if(ptrs[j] == NULL)
         printf("malloc NULL\n");
      else
         memset(ptrs[j], size[j], size[j]);
   }
   for(i = 0; i < 256; ++i)
   {
      if(ptrs[i])
         OS_HeapFree(ptrs[i]);
   }
#if 1
   for(i = 1000; i < 1000000; i += 1000)
   {
      ptr = OS_HeapMalloc(NULL, i);
      if(ptr == NULL)
         break;
      OS_HeapFree(ptr);
   }
   printf("Malloc max = %d\n", i);
#endif
   printf("Done.\n");
}

//******************************************************************
static void MyThreadMain(void *arg)
{
   OS_Thread_t *thread;
   int priority;

   thread = OS_ThreadSelf();
   priority = OS_ThreadPriorityGet(thread);
   OS_ThreadSleep(10);
   printf("Arg=%d thread=0x%x info=0x%x priority=%d\n", 
      (int)arg, (int)thread, (int)OS_ThreadInfoGet(thread, 0), priority);
   OS_ThreadExit();
}

static void TestThread(void)
{
   OS_Thread_t *thread;
   int i, priority;

   printf("TestThread\n");
   for(i = 0; i < 32; ++i)
   {
      priority = 50 + i;
      thread = OS_ThreadCreate("MyThread", MyThreadMain, (uint32*)i, priority, 0);
      if(thread == NULL)
         return;
      OS_ThreadInfoSet(thread, 0, (void*)(0xabcd + i));
      //printf("Created thread 0x%x\n", thread);
   }

   thread = OS_ThreadSelf();
   priority = OS_ThreadPriorityGet(thread);
   printf("Priority = %d\n", priority);
   OS_ThreadPrioritySet(thread, 200);
   printf("Priority = %d\n", OS_ThreadPriorityGet(thread));
   OS_ThreadPrioritySet(thread, priority);

   printf("Thread time = %d\n", OS_ThreadTime());
   OS_ThreadSleep(100);
   printf("Thread time = %d\n", OS_ThreadTime());
}

//******************************************************************
static void TestSemThread(void *arg)
{
   int i;
   TestInfo_t *info = (TestInfo_t*)arg;

   for(i = 0; i < SEMAPHORE_COUNT/2; ++i)
   {
      printf("s");
      OS_SemaphorePend(info->MySemaphore[i], OS_WAIT_FOREVER);
      OS_SemaphorePost(info->MySemaphore[i + SEMAPHORE_COUNT/2]);
   }
   OS_ThreadExit();
}

static void TestSemaphore(void)
{
   int i, rc;
   TestInfo_t info;
   printf("TestSemaphore\n");
   for(i = 0; i < SEMAPHORE_COUNT; ++i)
   {
      info.MySemaphore[i] = OS_SemaphoreCreate("MySem", 0);
      //printf("sem[%d]=0x%x\n", i, MySemaphore[i]);
   }

   OS_ThreadCreate("TestSem", TestSemThread, &info, 50, 0);

   for(i = 0; i < SEMAPHORE_COUNT/2; ++i)
   {
      printf("S");
      OS_SemaphorePost(info.MySemaphore[i]);
      rc = OS_SemaphorePend(info.MySemaphore[i + SEMAPHORE_COUNT/2], 500);
      assert(rc == 0);
   }

   printf(":");
   rc = OS_SemaphorePend(info.MySemaphore[0], 10);
   assert(rc != 0);
   printf(":");
   OS_SemaphorePend(info.MySemaphore[0], 100);
   printf(":");

   for(i = 0; i < SEMAPHORE_COUNT; ++i)
      OS_SemaphoreDelete(info.MySemaphore[i]);

   printf("\nDone.\n");
}

//******************************************************************
static void TestMutexThread(void *arg)
{
   TestInfo_t *info = (TestInfo_t*)arg;

   printf("Waiting for mutex\n");
   OS_MutexPend(info->MyMutex);
   printf("Have Mutex1\n");
   OS_MutexPend(info->MyMutex);
   printf("Have Mutex2\n");
   OS_MutexPend(info->MyMutex);
   printf("Have Mutex3\n");

   OS_ThreadSleep(100);

   OS_MutexPost(info->MyMutex);
   OS_MutexPost(info->MyMutex);
   OS_MutexPost(info->MyMutex);

   OS_ThreadExit();
}

//Test priority inversion
static void TestMutexThread2(void *arg)
{
   (void)arg;
   printf("Priority inversion test thread\n");
}

static void TestMutex(void)
{
   TestInfo_t info;
   printf("TestMutex\n");
   info.MyMutex = OS_MutexCreate("MyMutex");
   if(info.MyMutex == NULL)
      return;
   OS_MutexPend(info.MyMutex);
   OS_MutexPend(info.MyMutex);
   OS_MutexPend(info.MyMutex);
   printf("Acquired mutexes\n");

   OS_ThreadCreate("TestMutex", TestMutexThread, &info, 150, 0);
   OS_ThreadCreate("TestMutex2", TestMutexThread2, &info, 110, 0);

   printf("Posting mutexes at priority %d\n", 
      OS_ThreadPriorityGet(OS_ThreadSelf()));
   OS_MutexPost(info.MyMutex);
   OS_MutexPost(info.MyMutex);
   OS_MutexPost(info.MyMutex);
   printf("Thread priority %d\n", OS_ThreadPriorityGet(OS_ThreadSelf()));
   OS_ThreadSleep(50);

   printf("Try get mutex\n");
   OS_MutexPend(info.MyMutex);
   printf("Got it\n");

   OS_MutexDelete(info.MyMutex);
   OS_ThreadSleep(50);
   printf("Done.\n");
}

//******************************************************************
static void TestMQueue(void)
{
   OS_MQueue_t *mqueue;
   char data[16];
   int i, rc;

   printf("TestMQueue\n");
   mqueue = OS_MQueueCreate("MyMQueue", 10, 16);
   if(mqueue == NULL)
      return;
   strcpy(data, "Test0");
   for(i = 0; i < 16; ++i)
   {
      data[4] = (char)('0' + i);
      OS_MQueueSend(mqueue, data);
   }
   for(i = 0; i < 16; ++i)
   {
      memset(data, 0, sizeof(data));
      rc = OS_MQueueGet(mqueue, data, 20);
      if(rc == 0)
         printf("message=(%s)\n", data);
      else
         printf("timeout\n");
   }

   OS_MQueueDelete(mqueue);
   printf("Done.\n");
}

//******************************************************************
static void TestTimerThread(void *arg)
{
   int index;
   uint32 data[4];
   OS_Timer_t *timer;
   TestInfo_t *info = (TestInfo_t*)arg;

   //printf("TestTimerThread\n");

   OS_ThreadSleep(1);
   index = (int)OS_ThreadInfoGet(OS_ThreadSelf(), 0);
   //printf("index=%d\n", index);
   OS_MQueueGet(info->MyQueue[index], data, 1000);
   timer = (OS_Timer_t*)data[1];
   printf("%d ", data[2]);
   OS_MQueueGet(info->MyQueue[index], data, 1000);
   printf("%d ", data[2]);
   ++info->TimerDone;
   OS_ThreadExit();
}

static void TestTimer(void)
{
   int i;
   volatile TestInfo_t info;

   printf("TestTimer\n");
   info.TimerDone = 0;
   for(i = 0; i < TIMER_COUNT; ++i)
   {
      info.MyQueue[i] = OS_MQueueCreate("MyQueue", 10, 16);
      info.MyTimer[i] = OS_TimerCreate("MyTimer", info.MyQueue[i], i);
      info.MyThread[i] = OS_ThreadCreate("TimerTest", TestTimerThread, (void*)&info, 50, 0);
      OS_ThreadInfoSet(info.MyThread[i], 0, (void*)i);
      OS_TimerStart(info.MyTimer[i], 10+i*2, 220+i);
   }

   while(info.TimerDone < TIMER_COUNT)
      OS_ThreadSleep(10);

   for(i = 0; i < TIMER_COUNT; ++i)
   {
      OS_MQueueDelete(info.MyQueue[i]);
      OS_TimerDelete(info.MyTimer[i]);
   }

   printf("Done.\n");
}

//******************************************************************
#if 1
void TestMath(void)
{
   int i;
   float a, b, sum, diff, mult, div;
   uint32 compare;

   //Check add subtract multiply and divide
   for(i = -4; i < 4; ++i)
   {
      a = (float)(i * 10 + (float)63.2);
      b = (float)(-i * 5 + (float)3.5);
      sum = a + b;
      diff = a - b;
      mult = a * b;
      div = a / b;
      printf("a=%dE-3 b=%dE-3 sum=%dE-3 diff=%dE-3 mult=%dE-3 div=%dE-3\n",
         (int)(a*(float)1000), (int)(b*(float)1000), 
         (int)(sum*(float)1000), (int)(diff*(float)1000),
         (int)(mult*(float)1000), (int)(div*(float)1000));
   }

   //Comparisons
   b = (float)2.0;
   compare = 0;
   for(i = 1; i < 4; ++i)
   {
      a = (float)i;
      compare = (compare << 1) | (a == b);
      compare = (compare << 1) | (a != b);
      compare = (compare << 1) | (a <  b);
      compare = (compare << 1) | (a <= b);
      compare = (compare << 1) | (a >  b);
      compare = (compare << 1) | (a >= b);
   }
   printf("Compare = %8x %s\n", compare, 
      compare==0x1c953 ? "OK" : "ERROR");

   //Cosine
   for(a = (float)0.0; a <= (float)(3.1415); a += (float)(3.1415/16.0))
   {
      b = FP_Cos(a);
      printf("cos(%4dE-3) = %4dE-3\n", 
         (int)(a*(float)1000.0), (int)(b*(float)1000.0));
   }
}
#endif

//******************************************************************
#if OS_CPU_COUNT > 1
int SpinDone;
void ThreadSpin(void *arg)
{
   int i;
   int j = 0;
   unsigned int state;
   unsigned int timeStart = OS_ThreadTime();

   for(i = 0; i < 0x10000000; ++i)
   {
      if((i & 0xff) == 0)
      {
         state = OS_CriticalBegin();
         j += i;
         OS_CriticalEnd(state);
      }
      if(OS_ThreadTime() - timeStart > 400)
         break;
      if((i & 0xfffff) == 0)
         printf("[%d] ", (int)arg);
   }
   printf("done[%d].\n", (int)arg);
   ++SpinDone;
}

void TestSpin(void)
{
   int i;
   SpinDone = 0;
   for(i = 0; i < OS_CPU_COUNT; ++i)
      OS_ThreadCreate("Spin", ThreadSpin, (void*)i, 50+i, 0);
   for(i = 0; i < 100 && SpinDone < OS_CPU_COUNT; ++i)
      OS_ThreadSleep(1);
}
#endif

//******************************************************************
#ifndef WIN32
static void MySyscall(void *arg)
{
   uint32 *stack = arg;
   stack[STACK_EPC] += 4;  //skip over SYSCALL
   printf("Inside MySyscall %d\n", stack[28/4]);
}

void TestSyscall(void)
{
   OS_InterruptRegister((uint32)(1<<31), MySyscall);
   OS_Syscall(57);
   OS_ThreadSleep(1);
   printf("Done\n");
}
#endif

#ifdef __MMU_ENUM_H__
void TestProcess(void)
{
   OS_Process_t *process;
   process = (OS_Process_t*)OS_HeapMalloc(NULL, sizeof(OS_Process_t));
   process->name = "test";
   process->funcPtr = MainThread;
   process->arg = NULL;
   process->priority = 200;
   process->stackSize = 1024*32;
   process->heapSize = 1024*128;
   process->processId = 1;
   process->semaphoreDone = OS_SemaphoreCreate("processDone", 0);
   printf("Creating process\n");
   OS_MMUProcessCreate(process);
   OS_SemaphorePend(process->semaphoreDone, OS_WAIT_FOREVER);
   printf("Process done\n");
   OS_MMUProcessDelete(process);
}
#endif


//******************************************************************
void MMUTest(void);
void HtmlThread(void *arg);
void ConsoleInit(void);
uint8 macAddress[] =  {0x00, 0x10, 0xdd, 0xce, 0x15, 0xd4};


void MainThread(void *Arg)
{
   int ch, i, display=1;
   (void)Arg;
#ifdef __MMU_ENUM_H__
   OS_MMUInit();
#endif

#ifdef INCLUDE_ETH
   EthernetInit(macAddress);
   IPInit(EthernetTransmit, macAddress, "plasma");
   HtmlInit(1);
#endif

#ifdef INCLUDE_UART_PACKETS
   IPInit(NULL, macAddress, "plasma");
   HtmlInit(1);
#endif

#if !defined(EXCLUDE_CONSOLE) && (defined(INCLUDE_ETH) || defined(INCLUDE_UART_PACKETS))
   ConsoleInit();
#endif

   for(;;)
   {
      if(display)
      {
         printf("\n");
         printf("1 CLib\n");
         printf("2 Heap\n");
         printf("3 Thread\n");
         printf("4 Semaphore\n");
         printf("5 Mutex\n");
         printf("6 MQueue\n");
         printf("7 Timer\n");
         printf("8 Math\n");
         printf("9 Syscall\n");
#ifdef __MMU_ENUM_H__
         printf("p MMU Process\n");
#endif
      }
      printf("> ");
      display = 1;
      ch = UartRead();
      printf("%c\n", ch);
      switch(ch)
      {
#ifdef WIN32
      case '0': exit(0);
#endif
      case '1': TestCLib(); break;
      case '2': TestHeap(); break;
      case '3': TestThread(); break;
      case '4': TestSemaphore(); break;
      case '5': TestMutex(); break;
      case '6': TestMQueue(); break;
      case '7': TestTimer(); break;
      case '8': TestMath(); break;
#ifndef WIN32
      case '9': TestSyscall(); break;
#endif
#ifdef __MMU_ENUM_H__
      case 'p': TestProcess(); break;
#endif
#ifdef WIN32
      case 'm': TestMathFull(); break;
#endif
      case 'g': printf("Global=%d\n", ++Global); break;
#if OS_CPU_COUNT > 1
      case 's': TestSpin(); break;
#endif
      default: 
         printf("E");
         display = 0;
         for(i = 0; i < 30; ++i)
         {
            while(OS_kbhit())
               ch = UartRead();
            OS_ThreadSleep(1);
         }
         break;
      }
   }
}

