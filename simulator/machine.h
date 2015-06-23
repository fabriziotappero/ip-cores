#ifndef _MACHINE_H_
#define _MACHINE_H_

void machine_init(char *microcodepath, char *memorypath, unsigned int availmem, char *regpath, int cache_size);
void machine_shutdown(void);
void machine_shutup(void);
int machine_up(void);

#endif
