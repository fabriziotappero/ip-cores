#ifndef __LIB_STRING_H__
#define __LIB_STRING_H__

char *strncpy(char *dest, const char *src, int count);
int strcmp(const char *s1, const char *s2);
void *memset(void *p, int c, int size);
void *memcpy(void *d, void *s, int size);

#endif /* __LIB_STRING_H__ */
