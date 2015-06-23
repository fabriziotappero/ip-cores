#ifndef __LINKER_H__
#define __LINKER_H__

/*
 * Linker script-defined memory markers.
 */
extern unsigned long virtual_base[];
extern unsigned long __start_text[];
extern unsigned long __end_text[];
extern unsigned long __start_data[];
extern unsigned long __end_data[];
extern unsigned long __start_rodata[];
extern unsigned long __end_rodata[];
extern unsigned long __start_bss[];
extern unsigned long __end_bss[];

extern unsigned long __start_stack[];
extern unsigned long __stack[];

extern unsigned long __start_init[];
extern unsigned long __end_init[];
extern unsigned long __end[];

#endif /* __LINKER_H__ */
