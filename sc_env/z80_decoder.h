#ifndef Z80_DECODER_H_
#define Z80_DECODER_H_

#include <stdint.h>
#include "systemc.h"

typedef enum { UNPRE, PRE_CB, PRE_DD, PRE_ED, PRE_FD, DISP, IMM1, IMM2, IMM2B } dec_state;
  
SC_MODULE(z80_decoder)
{
private:
	dec_state state;
	sc_uint<8> opcode;
	char *op_name;
	char op_buf[80];
	uint16_t imm, op_addr;
	
	void decode_unpre();
	void op_print();
	
public:
	sc_in<bool>   clk;
	sc_in<uint32_t> addr;
	sc_in<bool>   m1_n;
	sc_in<bool>   mreq_n;
	sc_in<bool>   rd_n;
	sc_in<bool>   wait_n;
	sc_in<uint32_t> di;
	sc_in<bool>   reset_n;
	bool en_decode;

	void event();
	
	SC_CTOR(z80_decoder) {
		SC_METHOD (event);
		sensitive << clk.pos();
		en_decode = false;
	}
};

#endif /*Z80_DECODER_H_*/
