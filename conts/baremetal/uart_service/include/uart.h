
#ifndef __UART_SERVICE_H__
#define __UART_SERVICE_H__

#include <l4/api/capability.h>
#include <l4/generic/cap-types.h>

/*
 * uart structure ecapsulating
 * capability and virtual base address of uart
 */
struct uart {
	unsigned long base; /* VMA where uart will be mapped */
	struct capability cap;  /* Capability describing uart */
};

#endif /* __UART_SERVICE_H__ */
