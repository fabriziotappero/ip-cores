/*
 * ranlib.c - archive index generator
 */


#ifndef _RANLIB_H_
#define _RANLIB_H_


int hasSymbols(char *archive);
int updateSymbols(char *archive, int verbose);

int exec_rCmd(int create, char *args[]);


#endif /* _RANLIB_H_ */
