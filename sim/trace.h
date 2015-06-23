/*
 * trace.h -- trace buffer
 */


#ifndef _TRACE_H_
#define _TRACE_H_


#define TRACE_BUF_ADDR	12
#define TRACE_BUF_SIZE	(1 << TRACE_BUF_ADDR)
#define TRACE_BUF_MASK	(TRACE_BUF_SIZE - 1)


void traceFetch(Word pc);
void traceExec(Word instr, Word locus);
void traceLoadWord(Word addr);
void traceLoadHalf(Word addr);
void traceLoadByte(Word addr);
void traceStoreWord(Word addr);
void traceStoreHalf(Word addr);
void traceStoreByte(Word addr);
void traceException(Word priority);
char *traceShow(int back);

void traceReset(void);
void traceInit(void);
void traceExit(void);


#endif /* _TRACE_H_ */
