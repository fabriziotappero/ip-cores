/*
 * PL190 Primecell Vectored Interrupt Controller offsets
 *
 * Copyright (C) 2007 Bahadir Balban
 *
 */

#ifndef __PL190_VIC_H__
#define __PL190_VIC_H__

#include INC_PLAT(platform.h)
#include INC_ARCH(types.h)
#include INC_ARCH(io.h)

#define PL190_BASE				PLATFORM_IRQCTRL0_VBASE
#define PL190_SIC_BASE				PLATFORM_IRQCTRL1_VBASE

#define PL190_IRQS_MAX				32

/* VIC register offsets */
#define PL190_VIC_IRQSTATUS			(PL190_BASE + 0x00)
#define PL190_VIC_FIQSTATUS			(PL190_BASE + 0x04)
#define PL190_VIC_RAWINTR			(PL190_BASE + 0x08)
#define PL190_VIC_INTSELECT			(PL190_BASE + 0x0C)
#define PL190_VIC_INTENABLE			(PL190_BASE + 0x10)
#define PL190_VIC_INTENCLEAR			(PL190_BASE + 0x14)
#define PL190_VIC_SOFTINT			(PL190_BASE + 0x18)
#define PL190_VIC_SOFTINTCLEAR			(PL190_BASE + 0x1C)
#define PL190_VIC_PROTECTION			(PL190_BASE + 0x20)
#define PL190_VIC_VECTADDR			(PL190_BASE + 0x30)
#define PL190_VIC_DEFVECTADDR			(PL190_BASE + 0x34)
#define PL190_VIC_VECTADDR0			(PL190_BASE + 0x100)
/* 15 PIC_VECTADDR registers up to	0x13C */
#define PL190_VIC_VECTCNTL0			(PL190_BASE + 0x200)
/* 15 PIC_VECTCNTL registers up to	0x23C */

#define PL190_SIC_IRQS_MAX			32
#define PL190_SIC_STATUS			(PL190_SIC_BASE + 0x0)
#define PL190_SIC_RAWSTAT			(PL190_SIC_BASE + 0x04)
#define PL190_SIC_ENABLE			(PL190_SIC_BASE + 0x08)
#define PL190_SIC_ENSET				(PL190_SIC_BASE + 0x08)
#define PL190_SIC_ENCLR				(PL190_SIC_BASE + 0x0C)
#define PL190_SIC_SOFTINTSET			(PL190_SIC_BASE + 0x10)
#define PL190_SIC_SOFTINTCLR			(PL190_SIC_BASE + 0x14)
#define PL190_SIC_PICENABLE			(PL190_SIC_BASE + 0x20)
#define PL190_SIC_PICENSET			(PL190_SIC_BASE + 0x20)
#define PL190_SIC_PICENCLR			(PL190_SIC_BASE + 0x24)

void pl190_vic_init(void);
void pl190_ack_irq(l4id_t irq);
void pl190_mask_irq(l4id_t irq);
void pl190_unmask_irq(l4id_t irq);
l4id_t pl190_read_irq(void *irq_chip_data);

l4id_t pl190_sic_read_irq(void *irq_chip_data);
void pl190_sic_mask_irq(l4id_t irq);
void pl190_sic_mask_irq(l4id_t irq);
void pl190_sic_ack_irq(l4id_t irq);
void pl190_sic_unmask_irq(l4id_t irq);
void pl190_sic_init(void);

#endif /* __PL190_VIC_H__ */
