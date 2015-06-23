/*
 * Generic to arch-specific interface for
 * exchange_registers()
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include <l4/macros.h>
#include <l4lib/exregs.h>
#include L4LIB_INC_ARCH(syslib.h)
#include INC_GLUE(message.h)

void exregs_set_read(struct exregs_data *exregs)
{
	exregs->flags |= EXREGS_READ;
}

void exregs_print_registers(void)
{
	struct exregs_data exregs;

	/* Read registers */
	memset(&exregs, 0, sizeof(exregs));
	exregs.valid_vect = ~0;	/* Set all flags */
	exregs.flags |= EXREGS_READ;
	exregs.flags |= EXREGS_SET_UTCB;
	exregs.flags |= EXREGS_SET_PAGER;
	BUG_ON(l4_exchange_registers(&exregs, self_tid()) < 0);

	/* Print out registers */
	printf("Task (%x) register state upon fault:\n", self_tid());
	printf("R0: 0x%x\n", exregs.context.r0);
	printf("R1: 0x%x\n", exregs.context.r1);
	printf("R2: 0x%x\n", exregs.context.r2);
	printf("R3: 0x%x\n", exregs.context.r3);
	printf("R4: 0x%x\n", exregs.context.r4);
	printf("R5: 0x%x\n", exregs.context.r5);
	printf("R6: 0x%x\n", exregs.context.r6);
	printf("R7: 0x%x\n", exregs.context.r7);
	printf("R8: 0x%x\n", exregs.context.r8);
	printf("R9: 0x%x\n", exregs.context.r9);
	printf("R10: 0x%x\n", exregs.context.r10);
	printf("R11: 0x%x\n", exregs.context.r11);
	printf("R12: 0x%x\n", exregs.context.r12);
	printf("R13: 0x%x\n", exregs.context.sp);
	printf("R14: 0x%x\n", exregs.context.lr);
	printf("R15: 0x%x\n", exregs.context.pc);
	printf("Pager: 0x%x\n", exregs.pagerid);
	printf("Utcb @ 0x%lx\n", exregs.utcb_address);
}

void exregs_set_mr(struct exregs_data *s, int offset, unsigned long val)
{
	/* Get MR0 */
	u32 *mr = &s->context.MR0_REGISTER;

	/* Sanity check */
	BUG_ON(offset > MR_TOTAL || offset < 0);

	/* Set MR */
	mr[offset] = val;

	/* Set valid bit for mr register */
	s->valid_vect |= FIELD_TO_BIT(exregs_context_t, MR0_REGISTER) << offset;
}

void exregs_set_pager(struct exregs_data *s, l4id_t pagerid)
{
	s->pagerid = pagerid;
	s->flags |= EXREGS_SET_PAGER;
}

unsigned long exregs_get_utcb(struct exregs_data *s)
{
	return s->utcb_address;
}

unsigned long exregs_get_stack(struct exregs_data *s)
{
	return s->context.sp;
}

void exregs_set_utcb(struct exregs_data *s, unsigned long virt)
{
	s->utcb_address = virt;
	s->flags |= EXREGS_SET_UTCB;
}

void exregs_set_stack(struct exregs_data *s, unsigned long sp)
{
	s->context.sp = sp;
	s->valid_vect |= FIELD_TO_BIT(exregs_context_t, sp);
}

void exregs_set_pc(struct exregs_data *s, unsigned long pc)
{
	s->context.pc = pc;
	s->valid_vect |= FIELD_TO_BIT(exregs_context_t, pc);
}

