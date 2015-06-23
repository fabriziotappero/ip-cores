#include "decoder.h"

void decoder::do_decoder()
{
	sc_uint<32> uaddr;
	uaddr = dataaddr.read();
	
	switch(uaddr)
	{
		case 0x00006000: sel.write("001");
		break;
	
		case 0x00006004: sel.write("010");
		break;
	
		case 0x00006008: sel.write("011");
		break;
	
		case 0x0000600c: sel.write("100");
		break;
	
		case 0x00006010: sel.write("101");
		break;
	
		case 0x00006014: sel.write("110");
		break;
	
		case 0x00006018: sel.write("111");
		break;
	
		default: sel.write("000");
		break;
	}
} 
