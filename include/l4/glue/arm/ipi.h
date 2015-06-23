/*
 * Copyright (C) 2010 B Labs Ltd.
 *
 * By Bahadir Balban
 */
#ifndef __IPI_H__
#define __IPI_H__

#include <l4/generic/irq.h>

int ipi_handler(struct irq_desc *desc);


#define IPI_TIMER_EVENT		0

#endif	/* __IPI_H__ */
