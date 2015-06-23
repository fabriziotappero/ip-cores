/*
 * iolib.h -- I/O library
 */


#ifndef _IOLIB_H_
#define _IOLIB_H_


int strlen(char *str);
void strcpy(char *dst, char *src);
void memcpy(unsigned char *dst, unsigned char *src, unsigned int cnt);
char getchar(void);
void putchar(char c);
void putString(char *s);
void getLine(char *prompt, char *line, int max);
void vprintf(char *fmt, va_list ap);
void printf(char *fmt, ...);


#endif /* _IOLIB_H_ */
