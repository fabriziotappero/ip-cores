#include "di_mux.h"

void di_mux::event()
{
	uart_cs_n = 1;
	
	if (!mreq_n) {
		di = di_mem;
	} else if (!iorq_n) {
		if ((addr & 0xF8) == 0x18) {
			di = di_uart;
			uart_cs_n = 0;
		} else
			di = di_resp;
	} else
		di = 0;
}
