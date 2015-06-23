#ifndef _BREAKPOINT_H_
#define _BREAKPOINT_H_

#include "regs.h"

void breakpoint_init(void);
void breakpoint_list(void);
void breakpoint_set(reg_t addr);
void breakpoint_del(reg_t addr);
int breakpoint_at(reg_t addr);

#endif
