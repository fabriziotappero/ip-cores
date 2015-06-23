/*
 * console.h -- the simulator's operator console
 */


#ifndef _CONSOLE_H_
#define _CONSOLE_H_


char *cGetLine(char *prompt);
void cAddHist(char *line);
void cPrintf(char *format, ...);

void cInit(void);
void cExit(void);


#endif /* _CONSOLE_H_ */
