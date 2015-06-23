/*
 * shutdown.h -- shutdown device
 */


#ifndef _SHUTDOWN_H_
#define _SHUTDOWN_H_


Word shutdownRead(Word addr);
void shutdownWrite(Word addr, Word data);

void shutdownReset(void);
void shutdownInit(void);
void shutdownExit(void);


#endif /* _SHUTDOWN_H_ */
