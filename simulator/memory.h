#ifndef _MEMORY_H_
#define _MEMORY_H_

#include "types.h"
																
#define MEMORY_ADDRESS_SPACE_SIZE 0x100000000
#define DEFAULT_MEMORY_SIZE 1024*1024*2

int memory_init(unsigned int memsz, char *memfile);
void memory_load_from_file(char *memfile);
void memory_write_to_file(char *outfile);
void memory_write_part_to_file(char *memfile, int start, int length);
void memory_set(unsigned int pos, reg_t value);
reg_t memory_get(unsigned int pos);
int memory_size(void);

#endif /* _MEMORY_H_ */
