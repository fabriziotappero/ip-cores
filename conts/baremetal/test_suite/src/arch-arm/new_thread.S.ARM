#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(asm.h)

BEGIN_PROC(local_setup_new_thread)
	ldr	r0, [sp, #-4]!		@ Load first argument.
	mov	lr, pc			@ Save return address
	ldr	pc, [sp, #-4]!		@ Load function pointer from stack
new_thread_exit:
	b	new_thread_exit		@ We infinitely loop for now.
END_PROC(local_setup_new_thread)

