/*
 * Set up new thread's argument and call its function.
 * Return would be made to thread_exit with the return code.
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(asm.h)


BEGIN_PROC(setup_new_thread)
	ldr	r0, [sp, #-4]!		@ Load first argument
	mov	lr, pc			@ Save return address
	ldr	pc, [sp, #-4]!		@ Load function pointer from stack
	b	thread_exit		@ Call l4_thread_exit for cleanup
1:
	b	1b			@ Never reaches here
END_PROC(setup_new_thread)

