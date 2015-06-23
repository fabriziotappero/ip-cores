/*
 * Copyright (C) 2010 B Labs
 *
 * Author: Bahadir Balban
 */

#include <l4lib/arch/arm/asm.h>

/*
 * Atomically and destructively reads a byte. E.g.
 * byte is read and zero is written back. This is
 * useful on reading irq counts
 *
 * @r0 = byte address
 */
BEGIN_PROC(l4_atomic_dest_readb)
	mov	r1, #0
	swpb	r2, r1, [r0]
	mov	r0, r2
	mov	pc, lr
END_PROC(l4_atomic_dest_readb)




