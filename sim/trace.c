/*
 * trace.c -- trace buffer
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>

#include "common.h"
#include "console.h"
#include "error.h"
#include "except.h"
#include "disasm.h"
#include "trace.h"


#define TRACE_EMPTY		0
#define TRACE_FETCH		1
#define TRACE_EXEC		2
#define TRACE_LOAD_WORD		3
#define TRACE_LOAD_HALF		4
#define TRACE_LOAD_BYTE		5
#define TRACE_STORE_WORD	6
#define TRACE_STORE_HALF	7
#define TRACE_STORE_BYTE	8
#define TRACE_EXCEPTION		9


typedef struct {
  unsigned char type;
  Word data1;
  Word data2;
} TraceEntry;


static TraceEntry traceBuffer[TRACE_BUF_SIZE];
static int nextWrite;


/**************************************************************/


void traceFetch(Word pc) {
  traceBuffer[nextWrite].type = TRACE_FETCH;
  traceBuffer[nextWrite].data1 = pc;
  nextWrite = (nextWrite + 1) & TRACE_BUF_MASK;
}


void traceExec(Word instr, Word locus) {
  traceBuffer[nextWrite].type = TRACE_EXEC;
  traceBuffer[nextWrite].data1 = instr;
  traceBuffer[nextWrite].data2 = locus;
  nextWrite = (nextWrite + 1) & TRACE_BUF_MASK;
}


void traceLoadWord(Word addr) {
  traceBuffer[nextWrite].type = TRACE_LOAD_WORD;
  traceBuffer[nextWrite].data1 = addr;
  nextWrite = (nextWrite + 1) & TRACE_BUF_MASK;
}


void traceLoadHalf(Word addr) {
  traceBuffer[nextWrite].type = TRACE_LOAD_HALF;
  traceBuffer[nextWrite].data1 = addr;
  nextWrite = (nextWrite + 1) & TRACE_BUF_MASK;
}


void traceLoadByte(Word addr) {
  traceBuffer[nextWrite].type = TRACE_LOAD_BYTE;
  traceBuffer[nextWrite].data1 = addr;
  nextWrite = (nextWrite + 1) & TRACE_BUF_MASK;
}


void traceStoreWord(Word addr) {
  traceBuffer[nextWrite].type = TRACE_STORE_WORD;
  traceBuffer[nextWrite].data1 = addr;
  nextWrite = (nextWrite + 1) & TRACE_BUF_MASK;
}


void traceStoreHalf(Word addr) {
  traceBuffer[nextWrite].type = TRACE_STORE_HALF;
  traceBuffer[nextWrite].data1 = addr;
  nextWrite = (nextWrite + 1) & TRACE_BUF_MASK;
}


void traceStoreByte(Word addr) {
  traceBuffer[nextWrite].type = TRACE_STORE_BYTE;
  traceBuffer[nextWrite].data1 = addr;
  nextWrite = (nextWrite + 1) & TRACE_BUF_MASK;
}


void traceException(Word priority) {
  traceBuffer[nextWrite].type = TRACE_EXCEPTION;
  traceBuffer[nextWrite].data1 = priority;
  nextWrite = (nextWrite + 1) & TRACE_BUF_MASK;
}


char *traceShow(int back) {
  static char answer[100];
  int index;

  if (back < 1 || back > TRACE_BUF_SIZE) {
    return NULL;
  }
  index = (nextWrite - back) & TRACE_BUF_MASK;
  switch (traceBuffer[index].type) {
    case TRACE_EMPTY:
      sprintf(answer, "-- empty --");
      break;
    case TRACE_FETCH:
      sprintf(answer, "instr fetch, addr = %08X",
              traceBuffer[index].data1);
      break;
    case TRACE_EXEC:
      sprintf(answer, "instr exec, instr = %08X    %s",
              traceBuffer[index].data1,
              disasm(traceBuffer[index].data1,
                     traceBuffer[index].data2));
      break;
    case TRACE_LOAD_WORD:
      sprintf(answer, "load word, addr   = %08X",
              traceBuffer[index].data1);
      break;
    case TRACE_LOAD_HALF:
      sprintf(answer, "load half, addr   = %08X",
              traceBuffer[index].data1);
      break;
    case TRACE_LOAD_BYTE:
      sprintf(answer, "load byte, addr   = %08X",
              traceBuffer[index].data1);
      break;
    case TRACE_STORE_WORD:
      sprintf(answer, "store word, addr  = %08X",
              traceBuffer[index].data1);
      break;
    case TRACE_STORE_HALF:
      sprintf(answer, "store half, addr  = %08X",
              traceBuffer[index].data1);
      break;
    case TRACE_STORE_BYTE:
      sprintf(answer, "store byte, addr  = %08X",
              traceBuffer[index].data1);
      break;
    case TRACE_EXCEPTION:
      sprintf(answer, "****  exception %2d (%s)  ****",
              traceBuffer[index].data1,
              exceptionToString(traceBuffer[index].data1));
      break;
    default:
      error("unknown trace buffer entry");
  }
  return answer;
}


/**************************************************************/


void traceReset(void) {
  int i;

  cPrintf("Resetting Trace Buffer...\n");
  for (i = 0; i < TRACE_BUF_SIZE; i++) {
    traceBuffer[i].type = TRACE_EMPTY;
  }
  nextWrite = 0;
}


void traceInit(void) {
  traceReset();
}


void traceExit(void) {
}
