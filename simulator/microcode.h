#ifndef _MICROCODE_H_
#define _MICROCODE_H_

#include "types.h"

#define MICROCODE_MAX_SIZE 0x1000

int microcode_init(const char *path);
uint64_t microcode_fetch_instr(reg_t place);
size_t microcode_size(void);


#endif /* _MICROCODE_H_ */
