/*
 * lib.h -- the library
 */


#ifndef _LIB_H_
#define _LIB_H_


void debugBreak(void);

int strlen(const char *s);
int strcmp(const char *s, const char *t);
char *strcpy(char *s, const char *t);
char *strcat(char *s, const char *t);
char *strchr(const char *s, char c);
char *strtok(char *s, const char *t);

unsigned long strtoul(const char *s, char **endp, int base);

void qsort(void *base, int n, int size,
           int (*cmp)(const void *, const void *));

char getchar(void);
void putchar(char c);
void puts(const char *s);

int printf(const char *fmt, ...);
int sprintf(char *s, const char *fmt, ...);


#endif /* _LIB_H_ */
