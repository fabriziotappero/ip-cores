#ifndef __ARM_V5_UTCB_H__
#define __ARM_V5_UTCB_H__

/*
 * NOTE: Any changes you make here, you *MUST* change
 * utcb_address() macro in syscall.S assembler.
 */

/* Read Thread ID User RW register */
static inline u32 l4_cp15_read_tid_usr_rw(void)
{
	volatile u32 val;

	__asm__ __volatile__ (
		"mrc  p15, 0, %0, c13, c0, 2"
		: "=r" (val)
		:
	);

	return val;
}

/* Write Thread ID User RW register */
static inline void l4_cp15_write_tid_usr_rw(volatile u32 val)
{
	__asm__ __volatile__ (
		"mcr  p15, 0, %0, c13, c0, 2"
		:
		: "r" (val)
	);
}

/* Read Thread ID User RO register */
static inline u32 l4_cp15_read_tid_usr_ro(void)
{
	volatile u32 val;

	__asm__ __volatile__ (
		"mrc  p15, 0, %0, c13, c0, 3"
		: "=r" (val)
		:
	);

	return val;
}

/*
 * In ARMv7, utcb resides in the userspace read-only
 * thread register. This adds the benefit of avoiding
 * dirtying the cache and extra management for smp since
 * it is per-cpu.
 */
static inline struct utcb *l4_get_utcb()
{
//	printf("%s: UTCB Adddress: 0x%x\n", __FUNCTION__, l4_cp15_read_tid_usr_ro());
	return (struct utcb *)l4_cp15_read_tid_usr_ro();
}

#endif /* __ARM_V5_UTCB_H__ */
