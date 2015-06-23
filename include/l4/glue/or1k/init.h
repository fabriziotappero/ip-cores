/*
 * Copyright (C) 2010 B Labs Ltd.
 * Author: Prem Mallappa <prem.mallappa@b-labs.co.uk>
 */

#ifndef __ARM_GLUE_INIT_H__
#define __ARM_GLUE_INIT_H__

#include <l4/generic/tcb.h>
#include <l4/generic/space.h>

void switch_to_user(struct ktcb *inittask);
void timer_start(void);

extern struct address_space init_space;
void init_kernel_mappings(void);
void start_virtual_memory(void);
void finalize_virtual_memory(void);
void init_finalize(void);

void remove_section_mapping(unsigned long vaddr);

void vectors_init(void);
void setup_idle_caps(void);
void setup_idle_task(void);
#endif /* __ARM_GLUE_INIT_H__ */
