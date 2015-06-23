/*--------------------------------------------------------------------
 * TITLE: Plasma Real Time Operating System
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 12/17/05
 * FILENAME: rtos.h
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Plasma Real Time Operating System
 *    Fully pre-emptive RTOS with support for:
 *       Heaps, Threads, Semaphores, Mutexes, Message Queues, and Timers.
 *--------------------------------------------------------------------*/
#ifndef __RTOS_H__
#define __RTOS_H__

// Symmetric Multi-Processing
#define OS_CPU_COUNT 1

// Typedefs
typedef unsigned int   uint32;
typedef unsigned short uint16;
typedef unsigned char  uint8;

// Memory Access
#ifdef __TINYC__
   #define WIN32
#endif
#ifdef WIN32
   #define _CRT_SECURE_NO_WARNINGS 1
   #include <stdio.h>
   #include <assert.h>
   #include <setjmp.h>
   #define _LIBC
   uint32 MemoryRead(uint32 Address);
   void MemoryWrite(uint32 Address, uint32 Value);
#else
   #define MemoryRead(A) (*(volatile uint32*)(A))
   #define MemoryWrite(A,V) *(volatile uint32*)(A)=(V)
#endif

/***************** LibC ******************/
#undef isprint
#undef isspace
#undef isdigit
#undef islower
#undef isupper
#undef isalpha
#undef isalnum
#undef min
#define isprint(c) (' '<=(c)&&(c)<='~')
#define isspace(c) ((c)==' '||(c)=='\t'||(c)=='\n'||(c)=='\r')
#define isdigit(c) ('0'<=(c)&&(c)<='9')
#define islower(c) ('a'<=(c)&&(c)<='z')
#define isupper(c) ('A'<=(c)&&(c)<='Z')
#define isalpha(c) (islower(c)||isupper(c))
#define isalnum(c) (isalpha(c)||isdigit(c))
#define min(a,b)   ((a)<(b)?(a):(b))
#define strcpy     strcpy2  //don't use intrinsic functions
#define strncpy    strncpy2
#define strcat     strcat2
#define strncat    strncat2
#define strcmp     strcmp2
#define strncmp    strncmp2
#define strstr     strstr2
#define strlen     strlen2
#define memcpy     memcpy2
#define memmove    memmove2
#define memcmp     memcmp2
#define memset     memset2
#define abs        abs2
#define atoi       atoi2
#define rand       rand2
#define srand      srand2
#define strtol     strtol2
#define itoa       itoa2
#define sprintf    sprintf2
#define sscanf     sscanf2
#define malloc(S)  OS_HeapMalloc(NULL, S)
#define free(S)    OS_HeapFree(S)

char *strcpy(char *dst, const char *src);
char *strncpy(char *dst, const char *src, int count);
char *strcat(char *dst, const char *src);
char *strncat(char *dst, const char *src, int count);
int   strcmp(const char *string1, const char *string2);
int   strncmp(const char *string1, const char *string2, int count);
char *strstr(const char *string, const char *find);
int   strlen(const char *string);
void *memcpy(void *dst, const void *src, unsigned long bytes);
void *memmove(void *dst, const void *src, unsigned long bytes);
int   memcmp(const void *cs, const void *ct, unsigned long bytes);
void *memset(void *dst, int c, unsigned long bytes);
int   abs(int n);
int   atoi(const char *s);
int   rand(void);
void  srand(unsigned int seed);
long  strtol(const char *s, char **end, int base);
char *itoa(int num, char *dst, int base);

#ifndef NO_ELLIPSIS
   typedef char* va_list;
   #define va_start(AP,P) (AP=(char*)&(P)+sizeof(char*))
   #define va_arg(AP,T) (*(T*)((AP+=sizeof(T))-sizeof(T)))
   #define va_end(AP)
   int sprintf(char *s, const char *format, ...);
   int sscanf(const char *s, const char *format, ...);
#endif

#define printf     UartPrintf
#ifndef _LIBC
   #define assert(A) if((A)==0){OS_Assert();UartPrintfCritical("\r\nAssert %s:%d\r\n", __FILE__, __LINE__);}
   #define scanf     UartScanf
   #define NULL      (void*)0
#else
   #define UartPrintfCritical UartPrintf
#endif //_LIBC

#ifdef INCLUDE_DUMP
   void dump(const unsigned char *data, int length);
#endif
#ifdef INCLUDE_QSORT
   void qsort(void *base, 
              long n, 
              long size, 
              int (*cmp)(const void *,const void *));
   void *bsearch(const void *key,
                 const void *base,
                 long n,
                 long size,
                 int (*cmp)(const void *,const void *));
#endif
#ifdef INCLUDE_TIMELIB
   #define difftime(time2,time1) (time2-time1)
   typedef unsigned long time_t;  //start at 1/1/80
   struct tm {
      int tm_sec;      //(0,59)
      int tm_min;      //(0,59)
      int tm_hour;     //(0,23)
      int tm_mday;     //(1,31)
      int tm_mon;      //(0,11)
      int tm_year;     //(0,n) from 1900
      int tm_wday;     //(0,6)     calculated
      int tm_yday;     //(0,365)   calculated
      int tm_isdst;    //          calculated
   };
   time_t mktime(struct tm *tp);
   void gmtime_r(const time_t *tp, struct tm *out);
   void gmtimeDst(time_t dstTimeIn, time_t dstTimeOut);
   void gmtimeDstSet(time_t *tp, time_t *dstTimeIn, time_t *dstTimeOut);
#endif

/***************** Assembly **************/
#ifndef WIN32
typedef uint32 jmp_buf[20];
extern int setjmp(jmp_buf env);
extern void longjmp(jmp_buf env, int val);
#endif
extern uint32 OS_AsmInterruptEnable(uint32 state);
extern void OS_AsmInterruptInit(void);
extern uint32 OS_AsmMult(uint32 a, uint32 b, unsigned long *hi);
extern void *OS_Syscall(uint32 value);

/***************** Heap ******************/
typedef struct OS_Heap_s OS_Heap_t;
#define HEAP_USER    (OS_Heap_t*)0
#define HEAP_SYSTEM  (OS_Heap_t*)1
#define HEAP_SMALL   (OS_Heap_t*)2
#define HEAP_UI      (OS_Heap_t*)3
OS_Heap_t *OS_HeapCreate(const char *name, void *memory, uint32 size);
void OS_HeapDestroy(OS_Heap_t *heap);
void *OS_HeapMalloc(OS_Heap_t *heap, int bytes);
void OS_HeapFree(void *block);
void OS_HeapAlternate(OS_Heap_t *heap, OS_Heap_t *alternate);
void OS_HeapRegister(void *index, OS_Heap_t *heap);

/***************** Critical Sections *****************/
#if OS_CPU_COUNT <= 1
   // Single CPU
   #define OS_CpuIndex() 0
   #define OS_CriticalBegin() OS_AsmInterruptEnable(0)
   #define OS_CriticalEnd(S) OS_AsmInterruptEnable(S)
   #define OS_SpinLock() 0
   #define OS_SpinUnlock(S) 
#else
   // Symmetric multiprocessing
   uint32 OS_CpuIndex(void);
   #define OS_CriticalBegin() OS_SpinLock()
   #define OS_CriticalEnd(S) OS_SpinUnlock(S)
   uint32 OS_SpinLock(void);
   void OS_SpinUnlock(uint32 state);
#endif

/***************** Thread *****************/
#ifdef WIN32
   #define STACK_SIZE_MINIMUM (1024*8)
#else
   #define STACK_SIZE_MINIMUM (1024*1)
#endif
#define STACK_SIZE_DEFAULT 1024*2
#undef THREAD_PRIORITY_IDLE
#define THREAD_PRIORITY_IDLE 0
#define THREAD_PRIORITY_MAX 255

typedef void (*OS_FuncPtr_t)(void *arg);
typedef struct OS_Thread_s OS_Thread_t;
OS_Thread_t *OS_ThreadCreate(const char *name,
                             OS_FuncPtr_t funcPtr, 
                             void *arg, 
                             uint32 priority, 
                             uint32 stackSize);
void OS_ThreadExit(void);
OS_Thread_t *OS_ThreadSelf(void);
void OS_ThreadSleep(int ticks);
uint32 OS_ThreadTime(void);
void OS_ThreadInfoSet(OS_Thread_t *thread, uint32 index, void *info);
void *OS_ThreadInfoGet(OS_Thread_t *thread, uint32 index);
uint32 OS_ThreadPriorityGet(OS_Thread_t *thread);
void OS_ThreadPrioritySet(OS_Thread_t *thread, uint32 priority);
void OS_ThreadProcessId(OS_Thread_t *thread, uint32 processId, OS_Heap_t *heap);
void OS_ThreadCpuLock(OS_Thread_t *thread, int cpuIndex);

/***************** Semaphore **************/
#define OS_SUCCESS 0
#define OS_ERROR  -1
#define OS_WAIT_FOREVER -1
#define OS_NO_WAIT 0
typedef struct OS_Semaphore_s OS_Semaphore_t;
OS_Semaphore_t *OS_SemaphoreCreate(const char *name, uint32 count);
void OS_SemaphoreDelete(OS_Semaphore_t *semaphore);
int OS_SemaphorePend(OS_Semaphore_t *semaphore, int ticks); //tick ~= 10ms
void OS_SemaphorePost(OS_Semaphore_t *semaphore);

/***************** Mutex ******************/
typedef struct OS_Mutex_s OS_Mutex_t;
OS_Mutex_t *OS_MutexCreate(const char *name);
void OS_MutexDelete(OS_Mutex_t *semaphore);
void OS_MutexPend(OS_Mutex_t *semaphore);
void OS_MutexPost(OS_Mutex_t *semaphore);

/***************** MQueue *****************/
enum {
   MESSAGE_TYPE_USER = 0,
   MESSAGE_TYPE_TIMER = 5
};
typedef struct OS_MQueue_s OS_MQueue_t;
OS_MQueue_t *OS_MQueueCreate(const char *name,
                             int messageCount,
                             int messageBytes);
void OS_MQueueDelete(OS_MQueue_t *mQueue);
int OS_MQueueSend(OS_MQueue_t *mQueue, void *message);
int OS_MQueueGet(OS_MQueue_t *mQueue, void *message, int ticks);

/***************** Job ********************/
typedef void (*JobFunc_t)(void *a0, void *a1, void *a2);
void OS_Job(JobFunc_t funcPtr, void *arg0, void *arg1, void *arg2);

/***************** Timer ******************/
typedef struct OS_Timer_s OS_Timer_t;
typedef void (*OS_TimerFuncPtr_t)(OS_Timer_t *timer, uint32 info);
OS_Timer_t *OS_TimerCreate(const char *name, OS_MQueue_t *mQueue, uint32 info);
void OS_TimerDelete(OS_Timer_t *timer);
void OS_TimerCallback(OS_Timer_t *timer, OS_TimerFuncPtr_t callback);
void OS_TimerStart(OS_Timer_t *timer, uint32 ticks, uint32 ticksRestart);
void OS_TimerStop(OS_Timer_t *timer);

/***************** ISR ********************/
#define STACK_EPC 88/4
void OS_InterruptServiceRoutine(uint32 status, uint32 *stack);
void OS_InterruptRegister(uint32 mask, OS_FuncPtr_t funcPtr);
uint32 OS_InterruptStatus(void);
uint32 OS_InterruptMaskSet(uint32 mask);
uint32 OS_InterruptMaskClear(uint32 mask);

/***************** Init ******************/
void OS_Init(uint32 *heapStorage, uint32 bytes);
void OS_InitSimulation(void);
void OS_Start(void);
void OS_Assert(void);
void MainThread(void *Arg);

/***************** UART ******************/
typedef uint8* (*PacketGetFunc_t)(void);
void UartInit(void);
void UartWrite(int ch);
uint8 UartRead(void);
void UartWriteData(uint8 *data, int length);
void UartReadData(uint8 *data, int length);
#ifndef NO_ELLIPSIS2
void UartPrintf(const char *format, ...);
void UartPrintfPoll(const char *format, ...);
void UartPrintfCritical(const char *format, ...);
void UartPrintfNull(const char *format, ...);
void UartScanf(const char *format, ...);
#endif
void UartPacketConfig(PacketGetFunc_t packetGetFunc, 
                      int packetSize, 
                      OS_MQueue_t *mQueue);
void UartPacketSend(uint8 *data, int bytes);
int OS_puts(const char *string);
int OS_getch(void);
int OS_kbhit(void);
void LogWrite(int a);
void LogDump(void);
void Led(int mask, int value);

/***************** Keyboard **************/
#define KEYBOARD_RAW     0x100
#define KEYBOARD_E0      0x200
#define KEYBOARD_RELEASE 0x400
void KeyboardInit(void);
int KeyboardGetch(void);

/***************** Math ******************/
//IEEE single precision floating point math
#ifndef WIN32
#define FP_Neg     __negsf2
#define FP_Add     __addsf3
#define FP_Sub     __subsf3
#define FP_Mult    __mulsf3
#define FP_Div     __divsf3
#define FP_ToLong  __fixsfsi
#define FP_ToFloat __floatsisf
#define sqrt FP_Sqrt
#define cos  FP_Cos
#define sin  FP_Sin
#define atan FP_Atan
#define log  FP_Log
#define exp  FP_Exp
#endif
float FP_Neg(float a_fp);
float FP_Add(float a_fp, float b_fp);
float FP_Sub(float a_fp, float b_fp);
float FP_Mult(float a_fp, float b_fp);
float FP_Div(float a_fp, float b_fp);
long  FP_ToLong(float a_fp);
float FP_ToFloat(long af);
int   FP_Cmp(float a_fp, float b_fp);
float FP_Sqrt(float a);
float FP_Cos(float rad);
float FP_Sin(float rad);
float FP_Atan(float x);
float FP_Atan2(float y, float x);
float FP_Exp(float x);
float FP_Log(float x);
float FP_Pow(float x, float y);

/***************** Filesys ******************/
#ifndef EXCLUDE_FILESYS
#define FILE   OS_FILE
#define fopen  OS_fopen
#define fclose OS_fclose
#define fread  OS_fread
#define fwrite OS_fwrite
#define fseek  OS_fseek
#endif
#define _FILESYS_
typedef struct OS_FILE_s OS_FILE;
OS_FILE *OS_fopen(char *name, char *mode);
void OS_fclose(OS_FILE *file);
int OS_fread(void *buffer, int size, int count, OS_FILE *file);
int OS_fwrite(void *buffer, int size, int count, OS_FILE *file);
int OS_fseek(OS_FILE *file, int offset, int mode);
int OS_fmkdir(char *name);
int OS_fdir(OS_FILE *dir, char name[64]);
void OS_fdelete(char *name);
int OS_flength(char *entry);

/***************** Flash ******************/
void FlashLock(void);
void FlashUnlock(void);
void FlashRead(uint16 *dst, uint32 byteOffset, int bytes);
void FlashWrite(uint16 *src, uint32 byteOffset, int bytes);
void FlashErase(uint32 byteOffset);

#endif //__RTOS_H__

