
#include INC_PLAT(uart.h)
#include INC_PLAT(offsets.h)
#include INC_ARCH(io.h)

void print_early(char *str)
{
	unsigned int reg = 0;
	unsigned long uart_base;

	/* Check if mmu is on */
	__asm__ __volatile__ (
		"mrc     p15, 0, %0, c1, c0"
		: "=r" (reg)
                : "r" (reg)
	);

	/*
	 * Get uart phys/virt base based on mmu on/off
	 * Also strings are linked at virtual address, so if
	 * we are running with mmu off we should translate
	 * string address to physical
	 */
	if (reg & 1) {
		uart_base = PLATFORM_CONSOLE_VBASE;
	}
	else {
		uart_base = PLATFORM_UART0_BASE;
		str = (char *)(((unsigned long)str & ~KERNEL_AREA_START) |
			       PLATFORM_PHYS_MEM_START);
	}

	/* call uart tx function */
	while (*str != '\0') {
		uart_tx_char(uart_base, *str);

		if (*str == '\n')
			uart_tx_char(uart_base, '\r');

		++str;
	}
}

void printhex8(unsigned int val)
{
	char hexbuf[16];
	char *temp = hexbuf + 15;
	int v;

	/* put end of string */
	*(temp--) = '\0';

	if (!val) {
		*temp = '0';
	}
	else {
		while (val) {
			v = val & 0xf;
			val = val >> 4;
			--temp;

			/* convert decimal value to ascii */
			if (v >= 10)
				v += ('a' - 10);
			else
				v = v + '0';

			*temp = *((char *)&v);
		}
	}

	*(--temp) = 'x';
	*(--temp) = '0';
	print_early(temp);
}
