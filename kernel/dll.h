/*--------------------------------------------------------------------
 * TITLE: Plasma Dynamic Link Library
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 4/4/08
 * FILENAME: dll.h
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Dynamic Link Library 
 *--------------------------------------------------------------------*/
#ifndef __DLL_H__
#define __DLL_H__

#include "rtos.h"
#include "tcpip.h"

typedef void *(*DllFunc)();

// Included by Plasma Kernel to create array of function pointers
#ifdef DLL_SETUP

void *DllDummy(void) { printf("Dummy"); return NULL; }

const DllFunc DllFuncList[] = {
   (DllFunc)ConsolePrintf,
   (DllFunc)ConsoleScanf,
   (DllFunc)ConsoleKbhit,
   (DllFunc)ConsoleGetch,
   (DllFunc)strcpy,
   (DllFunc)strncpy,
   (DllFunc)strcat,
   (DllFunc)strncat,
   (DllFunc)strcmp,
   (DllFunc)strncmp,
   (DllFunc)strstr,
   (DllFunc)strlen,
   (DllFunc)memcpy,
   (DllFunc)memmove,
   (DllFunc)memcmp,
   (DllFunc)memset,
   (DllFunc)abs,
   (DllFunc)rand,
   (DllFunc)srand,
   (DllFunc)strtol,
   (DllFunc)atoi,
   (DllFunc)itoa,
   (DllFunc)sprintf,
   (DllFunc)sscanf,
#ifdef INCLUDE_DUMP
   (DllFunc)dump,
#else //INCLUDE_DUMP
   DllDummy,
#endif //INCLUDE_DUMP
#ifdef INCLUDE_QSORT
   (DllFunc)qsort,
   (DllFunc)bsearch,
#else //INCLUDE_QSORT
   DllDummy,
   DllDummy,
#endif //INCLUDE_QSORT
#ifdef INCLUDE_TIMELIB
   (DllFunc)mktime,
   (DllFunc)gmtime_r,
   (DllFunc)gmtimeDst,
   (DllFunc)gmtimeDstSet,
#else //INCLUDE_TIMELIB
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
#endif //INCLUDE_TIMELIB
   (DllFunc)OS_AsmInterruptEnable,
   (DllFunc)OS_HeapCreate,
   (DllFunc)OS_HeapDestroy,
   (DllFunc)OS_HeapMalloc,
   (DllFunc)OS_HeapFree,
   (DllFunc)OS_HeapAlternate,
   (DllFunc)OS_HeapRegister,
   (DllFunc)OS_ThreadCreate,
   (DllFunc)OS_ThreadExit,
   (DllFunc)OS_ThreadSelf,
   (DllFunc)OS_ThreadSleep,
   (DllFunc)OS_ThreadTime,
   (DllFunc)OS_ThreadInfoSet,
   (DllFunc)OS_ThreadInfoGet,
   (DllFunc)OS_ThreadPriorityGet,
   (DllFunc)OS_ThreadPrioritySet,
   (DllFunc)OS_ThreadProcessId,
   (DllFunc)OS_ThreadCpuLock,
   (DllFunc)OS_SemaphoreCreate,
   (DllFunc)OS_SemaphoreDelete,
   (DllFunc)OS_SemaphorePend,
   (DllFunc)OS_SemaphorePost,
   (DllFunc)OS_MutexCreate,
   (DllFunc)OS_MutexDelete,
   (DllFunc)OS_MutexPend,
   (DllFunc)OS_MutexPost,
   (DllFunc)OS_MQueueCreate,
   (DllFunc)OS_MQueueDelete,
   (DllFunc)OS_MQueueSend,
   (DllFunc)OS_MQueueGet,
   (DllFunc)OS_Job,
   (DllFunc)OS_TimerCreate,
   (DllFunc)OS_TimerDelete,
   (DllFunc)OS_TimerCallback,
   (DllFunc)OS_TimerStart,
   (DllFunc)OS_TimerStop,
   (DllFunc)OS_InterruptRegister,
   (DllFunc)OS_InterruptStatus,
   (DllFunc)OS_InterruptMaskSet,
   (DllFunc)OS_InterruptMaskClear,
   (DllFunc)UartPrintf,
   (DllFunc)UartPrintfCritical,
   (DllFunc)UartPrintfCritical,
   (DllFunc)UartScanf,
   (DllFunc)OS_puts,
   (DllFunc)OS_getch,
   (DllFunc)OS_kbhit,
   (DllFunc)Led,
#ifndef WIN32
   (DllFunc)__negsf2,
   (DllFunc)__addsf3,
   (DllFunc)__subsf3,
   (DllFunc)__mulsf3,
   (DllFunc)__divsf3,
   (DllFunc)__fixsfsi,
   (DllFunc)__floatsisf,
#else
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
#endif
   (DllFunc)FP_Sqrt,
   (DllFunc)FP_Cos,
   (DllFunc)FP_Sin,
   (DllFunc)FP_Atan,
   (DllFunc)FP_Atan2,
   (DllFunc)FP_Exp,
   (DllFunc)FP_Log,
   (DllFunc)FP_Pow,
#ifndef EXCLUDE_FILESYS
   (DllFunc)OS_fopen,
   (DllFunc)OS_fclose,
   (DllFunc)OS_fread,
   (DllFunc)OS_fwrite,
   (DllFunc)OS_fseek,
   (DllFunc)OS_fmkdir,
   (DllFunc)OS_fdir,
   (DllFunc)OS_fdelete,
#else //EXCLUDE_FILESYS
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
#endif //EXCLUDE_FILESYS
#ifndef EXCLUDE_FLASH
   (DllFunc)FlashRead,
   (DllFunc)FlashWrite,
   (DllFunc)FlashErase,
#else //WIN32
   DllDummy,
   DllDummy,
   DllDummy,
#endif //WIN32
   (DllFunc)IPOpen,
   (DllFunc)IPWriteFlush,
   (DllFunc)IPWrite,
   (DllFunc)IPRead,
   (DllFunc)IPClose,
   (DllFunc)IPPrintf,
   (DllFunc)IPResolve,
   (DllFunc)IPAddressSelf,
   (DllFunc)IPNameValue,
   (DllFunc)FP_Cmp,
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy,
   DllDummy
};

#endif //DLL_SETUP

// Included by DLL to call OS functions via array of function pointers
#if defined(DLL_CALL) || !defined(DLL_SETUP)

enum {
   ENUM_ConsolePrintf,
   ENUM_ConsoleScanf,
   ENUM_ConsoleKbhit,
   ENUM_ConsoleGetch,
   ENUM_strcpy,
   ENUM_strncpy,
   ENUM_strcat,
   ENUM_strncat,
   ENUM_strcmp,
   ENUM_strncmp,
   ENUM_strstr,
   ENUM_strlen,
   ENUM_memcpy,
   ENUM_memmove,
   ENUM_memcmp,
   ENUM_memset,
   ENUM_abs,
   ENUM_rand,
   ENUM_srand,
   ENUM_strtol,
   ENUM_atoi,
   ENUM_itoa,
   ENUM_sprintf,
   ENUM_sscanf,
   ENUM_dump,
   ENUM_qsort,
   ENUM_bsearch,
   ENUM_mktime,
   ENUM_gmtime_r,
   ENUM_gmtimeDst,
   ENUM_gmtimeDstSet,
   ENUM_OS_AsmInterruptEnable,
   ENUM_OS_HeapCreate,
   ENUM_OS_HeapDestroy,
   ENUM_OS_HeapMalloc,
   ENUM_OS_HeapFree,
   ENUM_OS_HeapAlternate,
   ENUM_OS_HeapRegister,
   ENUM_OS_ThreadCreate,
   ENUM_OS_ThreadExit,
   ENUM_OS_ThreadSelf,
   ENUM_OS_ThreadSleep,
   ENUM_OS_ThreadTime,
   ENUM_OS_ThreadInfoSet,
   ENUM_OS_ThreadInfoGet,
   ENUM_OS_ThreadPriorityGet,
   ENUM_OS_ThreadPrioritySet,
   ENUM_OS_ThreadProcessId,
   ENUM_OS_ThreadCpuLock,
   ENUM_OS_SemaphoreCreate,
   ENUM_OS_SemaphoreDelete,
   ENUM_OS_SemaphorePend,
   ENUM_OS_SemaphorePost,
   ENUM_OS_MutexCreate,
   ENUM_OS_MutexDelete,
   ENUM_OS_MutexPend,
   ENUM_OS_MutexPost,
   ENUM_OS_MQueueCreate,
   ENUM_OS_MQueueDelete,
   ENUM_OS_MQueueSend,
   ENUM_OS_MQueueGet,
   ENUM_OS_Job,
   ENUM_OS_TimerCreate,
   ENUM_OS_TimerDelete,
   ENUM_OS_TimerCallback,
   ENUM_OS_TimerStart,
   ENUM_OS_TimerStop,
   ENUM_OS_InterruptRegister,
   ENUM_OS_InterruptStatus,
   ENUM_OS_InterruptMaskSet,
   ENUM_OS_InterruptMaskClear,
   ENUM_UartPrintf,
   ENUM_UartPrintfPoll,
   ENUM_UartPrintfCritical,
   ENUM_UartScanf,
   ENUM_OS_puts,
   ENUM_OS_getch,
   ENUM_OS_kbhit,
   ENUM_Led,
   ENUM_NEGSF2,
   ENUM_ADDSF3,
   ENUM_SUBSF3,
   ENUM_MULSF3,
   ENUM_DIVSF3,
   ENUM_FIXSFSI,
   ENUM_FLOATSISF,
   ENUM_FP_Sqrt,
   ENUM_FP_Cos,
   ENUM_FP_Sin,
   ENUM_FP_Atan,
   ENUM_FP_Atan2,
   ENUM_FP_Exp,
   ENUM_FP_Log,
   ENUM_FP_Pow,
   ENUM_OS_fopen,
   ENUM_OS_fclose,
   ENUM_OS_fread,
   ENUM_OS_fwrite,
   ENUM_OS_fseek,
   ENUM_OS_fmkdir,
   ENUM_OS_fdir,
   ENUM_OS_fdelete,
   ENUM_FlashRead,
   ENUM_FlashWrite,
   ENUM_FlashErase,
   ENUM_IPOpen,
   ENUM_IPWriteFlush,
   ENUM_IPWrite,
   ENUM_IPRead,
   ENUM_IPClose,
   ENUM_IPPrintf,
   ENUM_IPResolve,
   ENUM_IPAddressSelf,
   ENUM_IPNameValue,
   ENUM_FP_Cmp,
   ENUM_USER0,
   ENUM_USER1,
   ENUM_USER2,
   ENUM_USER3,
   ENUM_USER4,
   ENUM_USER5,
   ENUM_USER6,
   ENUM_USER7,
   ARGV_SOCKET = -2
};

extern const DllFunc *DllF;

#undef strcpy
#undef strncpy
#undef strcat
#undef strncat
#undef strcmp
#undef strncmp
#undef strlen
#undef memcpy
#undef memcmp
#undef memmove
#undef memset
#undef abs
#undef atoi
#undef itoa
#undef srand
#undef rand
#undef sprintf
#undef sscanf
#undef strstr
#undef strtol
#undef scanf
#undef printf

#define printf (int)DllF[ENUM_ConsolePrintf]
#define scanf (int)DllF[ENUM_ConsoleScanf]
#define kbhit (int)DllF[ENUM_ConsoleKbhit]
#define getch (int)DllF[ENUM_ConsoleGetch]
#define strcpy DllF[ENUM_strcpy]
#define strncpy DllF[ENUM_strncpy]
#define strcat DllF[ENUM_strcat]
#define strncat DllF[ENUM_strncat]
#define strcmp (int)DllF[ENUM_strcmp]
#define strncmp (int)DllF[ENUM_strncmp]
#define strstr (char*)DllF[ENUM_strstr]
#define strlen (int)DllF[ENUM_strlen]
#define memcpy DllF[ENUM_memcpy]
#define memmove DllF[ENUM_memmove]
#define memcmp (int)DllF[ENUM_memcmp]
#define memset DllF[ENUM_memset]
#define abs (int)DllF[ENUM_abs]
#define rand (unsigned int)DllF[ENUM_rand]
#define srand DllF[ENUM_srand]
#define strtol (int)DllF[ENUM_strtol]
#define atoi (int)DllF[ENUM_atoi]
#define itoa DllF[ENUM_itoa]
#define sprintf (int)DllF[ENUM_sprintf]
#define sscanf (int)DllF[ENUM_sscanf]
#define dump DllF[ENUM_dump]
#define qsort DllF[ENUM_qsort]
#define bsearch DllF[ENUM_bsearch]
#define mktime DllF[ENUM_mktime]
#define gmtime_r DllF[ENUM_gmtime_r]
#define gmtimeDst DllF[ENUM_gmtimeDst]
#define gmtimeDstSet DllF[ENUM_gmtimeDstSet]
#define OS_AsmInterruptEnable (int)DllF[ENUM_OS_AsmInterruptEnable]
#define OS_HeapCreate DllF[ENUM_OS_HeapCreate]
#define OS_HeapDestroy DllF[ENUM_OS_HeapDestroy]
#define OS_HeapMalloc DllF[ENUM_OS_HeapMalloc]
#define OS_HeapFree DllF[ENUM_OS_HeapFree]
#define OS_HeapAlternate DllF[ENUM_OS_HeapAlternate]
#define OS_HeapRegister DllF[ENUM_OS_HeapRegister]
#define OS_ThreadCreate DllF[ENUM_OS_ThreadCreate]
#define OS_ThreadExit DllF[ENUM_OS_ThreadExit]
#define OS_ThreadSelf DllF[ENUM_OS_ThreadSelf]
#define OS_ThreadSleep DllF[ENUM_OS_ThreadSleep]
#define OS_ThreadTime (int)DllF[ENUM_OS_ThreadTime]
#define OS_ThreadInfoSet DllF[ENUM_OS_ThreadInfoSet]
#define OS_ThreadInfoGet DllF[ENUM_OS_ThreadInfoGet]
#define OS_ThreadPriorityGet (int)DllF[ENUM_OS_ThreadPriorityGet]
#define OS_ThreadPrioritySet DllF[ENUM_OS_ThreadPrioritySet]
#define OS_ThreadProcessId DllF[ENUM_OS_ThreadProcessId]
#define OS_ThreadCpuLock DllF[ENUM_OS_ThreadCpuLock]
#define OS_SemaphoreCreate DllF[ENUM_OS_SemaphoreCreate]
#define OS_SemaphoreDelete DllF[ENUM_OS_SemaphoreDelete]
#define OS_SemaphorePend (int)DllF[ENUM_OS_SemaphorePend]
#define OS_SemaphorePost DllF[ENUM_OS_SemaphorePost]
#define OS_MutexCreate DllF[ENUM_OS_MutexCreate]
#define OS_MutexDelete DllF[ENUM_OS_MutexDelete]
#define OS_MutexPend (int)DllF[ENUM_OS_MutexPend]
#define OS_MutexPost DllF[ENUM_OS_MutexPost]
#define OS_MQueueCreate DllF[ENUM_OS_MQueueCreate]
#define OS_MQueueDelete DllF[ENUM_OS_MQueueDelete]
#define OS_MQueueSend DllF[ENUM_OS_MQueueSend]
#define OS_MQueueGet (int)DllF[ENUM_OS_MQueueGet]
#define OS_Job DllF[ENUM_OS_Job]
#define OS_TimerCreate DllF[ENUM_OS_TimerCreate]
#define OS_TimerDelete DllF[ENUM_OS_TimerDelete]
#define OS_TimerCallback DllF[ENUM_OS_TimerCallback]
#define OS_TimerStart DllF[ENUM_OS_TimerStart]
#define OS_TimerStop DllF[ENUM_OS_TimerStop]
#define OS_InterruptRegister DllF[ENUM_OS_InterruptRegister]
#define OS_InterruptStatus (int)DllF[ENUM_OS_InterruptStatus]
#define OS_InterruptMaskSet DllF[ENUM_OS_InterruptMaskSet]
#define OS_InterruptMaskClear DllF[ENUM_OS_InterruptMaskClear]
#define UartPrintf DllF[ENUM_UartPrintf]
#define UartPrintfPoll DllF[ENUM_UartPrintfPoll]
#define UartPrintfCritical DllF[ENUM_UartPrintfCritical]
#define UartScanf DllF[ENUM_UartScanf]
#define OS_puts DllF[ENUM_OS_puts]
#define OS_getch (int)DllF[ENUM_OS_getch]
#define OS_kbhit (int)DllF[ENUM_OS_kbhit]
#define Led DllF[ENUM_Led]
#define FP_Sqrt (float)(int)DllF[ENUM_FP_Sqrt]
#define FP_Cos (float)(int)DllF[ENUM_FP_Cos]
#define FP_Sin (float)(int)DllF[ENUM_FP_Sin]
#define FP_Atan (float)(int)DllF[ENUM_FP_Atan]
#define FP_Atan2 (float)(int)DllF[ENUM_FP_Atan2]
#define FP_Exp (float)(int)DllF[ENUM_FP_Exp]
#define FP_Log (float)(int)DllF[ENUM_FP_Log]
#define FP_Pow (float)(int)DllF[ENUM_FP_Pow]
#define OS_fopen DllF[ENUM_OS_fopen]
#define OS_fclose DllF[ENUM_OS_fclose]
#define OS_fread (int)DllF[ENUM_OS_fread]
#define OS_fwrite (int)DllF[ENUM_OS_fwrite]
#define OS_fseek (int)DllF[ENUM_OS_fseek]
#define OS_fmkdir DllF[ENUM_OS_fmkdir]
#define OS_fdir DllF[ENUM_OS_fdir]
#define OS_fdelete DllF[ENUM_OS_fdelete]
#define FlashRead DllF[ENUM_FlashRead]
#define FlashWrite DllF[ENUM_FlashWrite]
#define FlashErase DllF[ENUM_FlashErase]
#define IPOpen DllF[ENUM_IPOpen]
#define IPWriteFlush DllF[ENUM_IPWriteFlush]
#define IPWrite (int)DllF[ENUM_IPWrite]
#define IPRead (int)DllF[ENUM_IPRead]
#define IPClose DllF[ENUM_IPClose]
#define IPPrintf (int)DllF[ENUM_IPPrintf]
#define IPResolve DllF[ENUM_IPResolve]
#define IPAddressSelf (int)DllF[ENUM_IPAddressSelf]
#define IPNameValue DllF[ENUM_IPNameValue]
#define UserFunc0 DllF[ENUM_USER0]
#define UserFunc1 DllF[ENUM_USER1]
#define time(P) OS_ThreadTime()

#endif //DLL_CALL


#if defined(DLL_SETUP) && defined(DLL_CALL)
const DllFunc *DllF = DllFuncList;
#elif !defined(DLL_SETUP) && !defined(DLL_CALL) && !defined(DLL_ENTRY)
#define DLL_ENTRY 1
#endif //DLL_SETUP && DLL_CALL


// Included by DLL to initialize the DLL
#if defined(DLL_ENTRY) && !defined(NO_DLL_ENTRY)
const DllFunc *DllF;         //array of function pointers
int main(int argc, char *argv[]);

//Must be first function in file
int __start(int argc, char *argv[])
{
   extern void *__bss_start;
   extern void *_end;
   int *bss = (int*)&__bss_start;

   if(bss == (int*)DllF)
      ++bss;
   while(bss < (int*)&_end)
      *bss++ = 0;
   DllF = (DllFunc*)argv[-1];
   return main(argc, argv);
}

#ifdef INCLUDE_MATH
typedef float (*DllFloat)(float);
typedef float (*DllFloat2)(float,float);
typedef long (*DllFloat3)(float);
typedef int (*DllFloat4)(float,float);
typedef float (*DllFloat5)(long a);
float __negsf2(float a) {return ((DllFloat)DllF[ENUM_NEGSF2])(a);}
float __addsf3(float a,float b) {return ((DllFloat2)DllF[ENUM_ADDSF3])(a,b);}
float __subsf3(float a,float b) {return ((DllFloat2)DllF[ENUM_SUBSF3])(a,b);}
float __mulsf3(float a,float b) {return ((DllFloat2)DllF[ENUM_MULSF3])(a,b);}
float __divsf3(float a,float b) {return ((DllFloat2)DllF[ENUM_DIVSF3])(a,b);}
long __fixsfsi(float a) {return ((DllFloat3)DllF[ENUM_FIXSFSI])(a);}
float __floatsisf(long a) {return ((DllFloat5)DllF[ENUM_FLOATSISF])(a);}
int __ltsf2(float a,float b) {return ((DllFloat4)DllF[ENUM_FP_Cmp])(a,b);}
int __lesf2(float a,float b) {return ((DllFloat4)DllF[ENUM_FP_Cmp])(a,b);}
int __gtsf2(float a,float b) {return ((DllFloat4)DllF[ENUM_FP_Cmp])(a,b);}
int __gesf2(float a,float b) {return ((DllFloat4)DllF[ENUM_FP_Cmp])(a,b);}
#endif

#endif //DLL_ENTRY


#ifdef DLL_STRINGS
const char * const DllStrings[] = {
   "printf",
   "scanf",
   "kbhit",
   "getch",
   "strcpy",
   "strncpy",
   "strcat",
   "strncat",
   "strcmp",
   "strncmp",
   "strstr",
   "strlen",
   "memcpy",
   "memmove",
   "memcmp",
   "memset",
   "abs",
   "rand",
   "srand",
   "strtol",
   "atoi",
   "itoa",
   "sprintf",
   "sscanf",
   "dump",
   "qsort",
   "bsearch",
   "mktime",
   "gmtime_r",
   "gmtimeDst",
   "gmtimeDstSet",
   "OS_AsmInterruptEnable",
   "OS_HeapCreate",
   "OS_HeapDestroy",
   "OS_HeapMalloc",
   "OS_HeapFree",
   "OS_HeapAlternate",
   "OS_HeapRegister",
   "OS_ThreadCreate",
   "OS_ThreadExit",
   "OS_ThreadSelf",
   "OS_ThreadSleep",
   "OS_ThreadTime",
   "OS_ThreadInfoSet",
   "OS_ThreadInfoGet",
   "OS_ThreadPriorityGet",
   "OS_ThreadPrioritySet",
   "OS_ThreadProcessId",
   "OS_ThreadCpuLock",
   "OS_SemaphoreCreate",
   "OS_SemaphoreDelete",
   "OS_SemaphorePend",
   "OS_SemaphorePost",
   "OS_MutexCreate",
   "OS_MutexDelete",
   "OS_MutexPend",
   "OS_MutexPost",
   "OS_MQueueCreate",
   "OS_MQueueDelete",
   "OS_MQueueSend",
   "OS_MQueueGet",
   "OS_Job",
   "OS_TimerCreate",
   "OS_TimerDelete",
   "OS_TimerCallback",
   "OS_TimerStart",
   "OS_TimerStop",
   "OS_InterruptRegister",
   "OS_InterruptStatus",
   "OS_InterruptMaskSet",
   "OS_InterruptMaskClear",
   "UartPrintf",
   "UartPrintfPoll",
   "UartPrintfCritical",
   "UartScanf",
   "OS_puts",
   "OS_getch",
   "OS_kbhit",
   "Led",
   "FP_Neg",
   "FP_Add",
   "FP_Sub",
   "FP_Mult",
   "FP_Div",
   "FP_ToInt",
   "FP_ToLong",
   "FP_Sqrt",
   "FP_Cos",
   "FP_Sin",
   "FP_Atan",
   "FP_Atan2",
   "FP_Exp",
   "FP_Log",
   "FP_Pow",
   "OS_fopen",
   "OS_fclose",
   "OS_fread",
   "OS_fwrite",
   "OS_fseek",
   "OS_fmkdir",
   "OS_fdir",
   "OS_fdelete",
   "FlashRead",
   "FlashWrite",
   "FlashErase",
   "IPOpen",
   "IPWriteFlush",
   "IPWrite",
   "IPRead",
   "IPClose",
   "IPPrintf",
   "IPResolve",
   "IPAddressSelf",
   "IPNameValue",
   "FP_Cmp",
   NULL
};
#endif //DLL_STRINGS

#endif //__DLL_H__

