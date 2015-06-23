#ifndef __SERIAL_H__
#define __SERIAL_H__

//-----------------------------------------------------------------
// Prototypes:
//-----------------------------------------------------------------
void serial_init (void);
int  serial_putchar(char ch);
int  serial_getchar(void);
int  serial_haschar();
void serial_putstr(char *str);

#endif // __SERIAL_H__
