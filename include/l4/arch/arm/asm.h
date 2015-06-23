
#ifndef __ARCH_ARM_ASM_H__
#define __ARCH_ARM_ASM_H__


/* Top nibble of the byte denotes irqs/fiqs disabled, ARM state */
#define ARM_MODE_MASK	0x1F

#define	ARM_MODE_SVC	0x13
#define ARM_MODE_UND	0x1B
#define ARM_MODE_ABT	0x17
#define ARM_MODE_IRQ	0x12
#define ARM_MODE_FIQ	0x11
#define ARM_MODE_USR	0x10
#define ARM_MODE_SYS	0x1F
#define	ARM_NOIRQ_SVC	0xD3
#define ARM_NOIRQ_UND	0xDB
#define ARM_NOIRQ_ABT	0xD7
#define ARM_NOIRQ_IRQ	0xD2
#define ARM_NOIRQ_FIQ	0xD1
#define ARM_NOIRQ_USR	0xD0
#define ARM_NOIRQ_SYS	0xDF

/* For enabling *clear* these bits */
#define ARM_IRQ_BIT	0x080
#define ARM_FIQ_BIT	0x040
#define ARM_A_BIT	0x100 /* Asynchronous abort */

/* Notes about ARM instructions:
 *
 * TST instruction:
 *
 * Essentially TST "AND"s two values and the result affects the Z (Zero bit)
 * in CPSR, which can be used for conditions. For example in:
 *
 * 	TST r0, #VALUE
 *
 * If anding r0 and #VALUE results in a positive value (i.e. they have a
 * common bit set as 1) then Z bit is 0, which accounts for an NE (Not equal)
 * condition. Consequently, e.g. a BEQ instruction would be skipped and a BNE
 * would be executed.
 *
 * In the opposite case, r0 and #VALUE has no common bits, and anding them
 * results in 0. This means Z bit is 1, and any EQ instruction coming afterwards
 * would be executed.
 *
 * I have made this explanation here because I think the behaviour of the Z bit
 * is not very clear in TST. Normally Z bit is used for equivalence (e.g. CMP
 * instruction) but in TST case even if two values were equal the Z bit could
 * point to an NE or EQ condition depending on whether the values have non-zero
 * bits.
 */


#define dbg_stop_here()		__asm__ __volatile__ (	"bkpt	#0\n" :: )

#define BEGIN_PROC(name)			\
    .global name; 				\
    .type   name,function;			\
    .align;					\
name:

#define END_PROC(name)				\
.fend_##name:					\
    .size   name,.fend_##name - name;

#endif /* __ARCH_ARM_ASM_H__ */
