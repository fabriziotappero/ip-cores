// The Potato Processor
// (c) Kristian Klomsten Skordal 2015 <kristian.skordal@wafflemail.net>
// Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

#ifndef POTATO_H
#define POTATO_H

// This file contains various defines neccessary for using the Potato processor
// with current RISC-V compilers. It also makes sure that applications keep
// working even though the supervisor extension specification should change.

// Control and status registers:
#define CSR_SUP0	0x500
#define CSR_SUP1	0x501
#define CSR_EPC		0x502
#define CSR_BADVADDR	0x503
#define CSR_EVEC	0x508
#define CSR_CAUSE	0x509
#define CSR_STATUS	0x50a
#define CSR_HARTID	0x50b
#define CSR_TOHOST	0x51e
#define CSR_FROMHOST	0x51f
#define CSR_CYCLE	0xc00
#define CSR_CYCLEH	0xc80
#define CSR_TIME	0xc01
#define CSR_TIMEH	0xc81
#define CSR_INSTRET	0xc02
#define CSR_INSTRETH	0xc82

// Exception cause values:
#define CAUSE_INSTR_MISALIGN	0x00
#define CAUSE_INSTR_FETCH	0x01
#define CAUSE_INVALID_INSTR	0x02
#define CAUSE_SYSCALL		0x06
#define CAUSE_BREAKPOINT	0x07
#define CAUSE_LOAD_MISALIGN	0x08
#define CAUSE_STORE_MISALIGN	0x09
#define CAUSE_LOAD_ERROR	0x0a
#define CAUSE_STORE_ERROR	0x0b
#define CAUSE_FROMHOST		0x1e

#define CAUSE_IRQ_BASE		0x10

// Status register bit indices:
#define STATUS_EI	2		// Enable Interrupts
#define STATUS_PEI	3		// Previous value of Enable Interrupts
#define STATUS_IM_MASK	0x00ff0000	// Interrupt Mask
#define STATUS_PIM_MASK	0xff000000	// Previous Interrupt Mask

#define potato_enable_interrupts()	asm volatile("csrsi %[status], 1 << %[ei_bit]\n" \
		:: [status] "i" (CSR_STATUS), [ei_bit] "i" (STATUS_EI))
#define potato_disable_interrupts()	asm volatile("csrci %[status], 1 << %[ei_bit] | 1 << %[pei_bit]\n" \
		:: [status] "i" (CSR_STATUS), [ei_bit] "i" (STATUS_EI), [pei_bit] "i" (STATUS_PEI))

#define potato_write_host(data)	\
	do { \
		register uint32_t temp = data; \
		asm volatile("csrw %[tohost], %[temp]\n" \
			:: [tohost] "i" (CSR_TOHOST), [temp] "r" (temp)); \
	} while(0);

#define potato_enable_irq(n) \
	do { \
		register uint32_t temp = 0; \
		asm volatile( \
			"li %[temp], 1 << %[shift]\n" \
			"csrs %[status], %[temp]\n" \
			:: [temp] "r" (temp), [shift] "i" (n + 16), [status] "i" (CSR_STATUS)); \
	} while(0)

#define potato_disable_irq(n) \
	do { \
		register uint32_t temp = 0; \
		asm volatile( \
			"li %[temp], 1 << %[shift]\n" \
			"csrc %[status], %[temp]\n" \
			:: [temp] "r" (temp), [shift] "i" (n + 24), [status] "i" (CSR_STATUS)); \
	} while(0)

#define potato_get_badvaddr(n) \
	do { \
		register uint32_t __temp = 0; \
		asm volatile ( \
			"csrr %[temp], %[badvaddr]\n" \
			: [temp] "=r" (__temp) : [badvaddr] "i" (CSR_BADVADDR)); \
		n = __temp; \
	} while(0)

#endif

