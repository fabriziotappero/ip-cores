/*
 * Copyright (C) 2009 Bahadir Balban
 */

/*
 * We expect initial stack state:
 *
 * (low) |->argc|argv[0]|argv[1]|...|argv[argc] = 0|envp[0]|...|NULL| (high)
 *
 */

.section .text.head
	.global _start;
	.align;
_start:
	bl	platform_init
	mov 	fp, #0		@ Clear frame pointer
	mov 	lr, #0		@ Clear link register
	ldmfd 	sp!, {r0}	@ Argc value in r0
	mov	r1, sp  	@ Ptr to argv in r1

	bl	__container_init
1:
	b	1b

