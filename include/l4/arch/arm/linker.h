/*
 * Linker-defined variables
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#ifndef __ARCH_ARM_LINKER_H__
#define __ARCH_ARM_LINKER_H__

extern unsigned long _start_kernel[];
extern unsigned long _start_text[];
extern unsigned long _end_text[];
extern unsigned long _start_data[];
extern unsigned long _end_data[];
extern unsigned long _start_vectors[];
extern unsigned long arm_high_vector[];
extern unsigned long _end_vectors[];
extern unsigned long _start_kip[];
extern unsigned long _end_kip[];
extern unsigned long _start_syscalls[];
extern unsigned long _end_syscalls[];
extern unsigned long _start_init[];
extern unsigned long _end_init[];
extern unsigned long _start_bootstack[];
extern unsigned long _end_bootstack[];
extern unsigned long _start_init_pgd[];
extern unsigned long _end_init_pgd[];

extern unsigned long _end_kernel[];
extern unsigned long _end[];

/* Link markers that get modified at runtime */
unsigned long __svc_images_end;
unsigned long __pt_start;
unsigned long __pt_end;

#endif /* __ARCH_ARM_LINKER_H__ */
