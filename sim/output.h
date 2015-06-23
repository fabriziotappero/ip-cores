/*
 * output.h -- output to file on host system
 */


#ifndef _OUTPUT_H_
#define _OUTPUT_H_


Word outputRead(Word addr);
void outputWrite(Word addr, Word data);

void outputReset(void);
void outputInit(char *outputFileName);
void outputExit(void);


#endif /* _OUTPUT_H_ */
