#ifndef DI_MUX_H_
#define DI_MUX_H_

#include "sc_env.h"

SC_MODULE (di_mux)
{
public:
	sc_in<bool>      mreq_n;
	sc_in<bool>      iorq_n;
	sc_in<uint32_t>  addr;
	sc_in<uint32_t>  di_mem;
	sc_in<uint32_t>  di_resp;
	sc_in<uint32_t>  di_uart;
	sc_out<uint32_t> di;
	sc_out<bool>     uart_cs_n;
	
	void event();
	
	SC_CTOR(di_mux) {
		SC_METHOD(event);
		sensitive << mreq_n << iorq_n << addr << di_mem << di_resp << di_uart;
	}
};

#endif /*DI_MUX_H_*/
