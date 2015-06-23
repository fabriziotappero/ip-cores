/*--------------------------------------------------------------------
 * TITLE: Plasma Real Time Operating System Extensions
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 12/17/05
 * FILENAME: rtos_ex.c
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Support simulation under Windows.
 *    Support simulating multiple CPUs using symmetric multiprocessing.
 *--------------------------------------------------------------------*/
#include "plasma.h"
#define NO_ELLIPSIS2
#include "rtos.h"

/************** WIN32 Simulation Support *************/
#ifdef WIN32
#include <conio.h>
#define kbhit _kbhit
#define getch _getch
#define putch _putch
extern void __stdcall Sleep(unsigned long value);

#if OS_CPU_COUNT > 1
unsigned int __stdcall GetCurrentThreadId(void);
typedef void (*LPTHREAD_START_ROUTINE)(void *lpThreadParameter);
void * __stdcall CreateThread(void *lpsa, unsigned int dwStackSize,
   LPTHREAD_START_ROUTINE pfnThreadProc, void *pvParam, 
   unsigned int dwCreationFlags, unsigned int *pdwThreadId);
   
static unsigned int ThreadId[OS_CPU_COUNT];

//PC simulation of multiple CPUs
void OS_InitSimulation(void)
{  

   int i;
   ThreadId[0] = GetCurrentThreadId();
   for(i = 1; i < OS_CPU_COUNT; ++i)
      CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)OS_Start, NULL, 0, &ThreadId[i]);
}
#endif  //OS_CPU_COUNT > 1
#else   //NWIN32
#include <unistd.h>
#define kbhit() 1
#define getch getchar
#define putch putchar
#define Sleep(X) usleep(X*1000)
#endif  //WIN32


static uint32 Memory[8];

//Simulates device register memory reads
uint32 MemoryRead(uint32 address)
{
   Memory[2] |= IRQ_UART_WRITE_AVAILABLE;    //IRQ_STATUS
   switch(address)
   {
   case UART_READ: 
      if(kbhit())
         Memory[0] = getch();                //UART_READ
      Memory[2] &= ~IRQ_UART_READ_AVAILABLE; //clear bit
      return Memory[0];
   case IRQ_MASK: 
      return Memory[1];                      //IRQ_MASK
   case IRQ_MASK + 4:
      Sleep(10);
      return 0;
   case IRQ_STATUS: 
      if(kbhit())
         Memory[2] |= IRQ_UART_READ_AVAILABLE;
      return Memory[2];
   }
   return 0;
}

//Simulates device register memory writes
void MemoryWrite(uint32 address, uint32 value)
{
   switch(address)
   {
   case UART_WRITE: 
      putch(value); 
      break;
   case IRQ_MASK:   
      Memory[1] = value; 
      break;
   case IRQ_STATUS: 
      Memory[2] = value; 
      break;
   }
}

uint32 OS_AsmInterruptEnable(uint32 enableInterrupt)
{
   return enableInterrupt;
}

void OS_AsmInterruptInit(void)
{
}

void UartInit(void) {}
uint8 UartRead(void) {return getch();}
int OS_kbhit(void) {return kbhit();}
void UartPrintf(const char *format,
                int arg0, int arg1, int arg2, int arg3,
                int arg4, int arg5, int arg6, int arg7)
{
   char buffer[256], *ptr = buffer;

   sprintf(buffer, format, arg0, arg1, arg2, arg3,
           arg4, arg5, arg6, arg7);
   while(ptr[0])
      putchar(*ptr++);
}


#if OS_CPU_COUNT > 1
static volatile uint8 SpinLockArray[OS_CPU_COUNT];
/******************************************/
uint32 OS_CpuIndex(void)
{
#ifdef WIN32
   int i;
   unsigned int threadId=GetCurrentThreadId();
   for(i = 0; i < OS_CPU_COUNT; ++i)
   {
      if(threadId == ThreadId[i])
         return i;
   }
#endif
   //return MemoryRead(GPIO_CPU_INDEX);
   return 0; //0 to OS_CPU_COUNT-1
}


/******************************************/
//Symmetric Multiprocessing Spin Lock Mutex
uint32 OS_SpinLock(void)
{
   uint32 state, cpuIndex, i, ok, delay;
   volatile uint32 keepVar;

   cpuIndex = OS_CpuIndex();
   state = OS_AsmInterruptEnable(0);    //disable interrupts
   if(SpinLockArray[cpuIndex])
      return (uint32)-1;                //already locked
   delay = (4 + cpuIndex) << 2;

   //Spin until only this CPU has the spin lock
   for(;;)
   {
      ok = 1;
      SpinLockArray[cpuIndex] = 1;
      for(i = 0; i < OS_CPU_COUNT; ++i)
      {
         if(i != cpuIndex && SpinLockArray[i])
            ok = 0;   //Another CPU has the spin lock
      }
      if(ok)
         return state;
      SpinLockArray[cpuIndex] = 0;
      OS_AsmInterruptEnable(state);     //re-enable interrupts
      for(i = 0; i < delay; ++i)        //wait a bit
         ++ok;
      keepVar = ok;    //don't optimize away the delay loop
      if(delay < 128)
         delay <<= 1;
      state = OS_AsmInterruptEnable(0); //disable interrupts
   }
}


/******************************************/
void OS_SpinUnlock(uint32 state)
{
   uint32 cpuIndex;
   if(state == (uint32)-1)
      return;                           //nested lock call
   cpuIndex = OS_CpuIndex();
   SpinLockArray[cpuIndex] = 0;
}
#endif  //OS_CPU_COUNT > 1

