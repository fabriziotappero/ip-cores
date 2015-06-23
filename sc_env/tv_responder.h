#ifndef TV_RESPONDER_H_
#define TV_RESPONDER_H_

#include "sc_env.h"
#include "tv80_scenv.h"

SC_MODULE(tv_responder)
{
  private:
	char    str_buf [256];
	int     buf_ptr;
	
	int     timeout_ctl;
	int     cur_timeout;
	int     max_timeout;
	
	int     int_countdown;
	int     nmi_countdown;
	uint8_t checksum;
	int     ior_value;  // increment-on-read value
	int     nmi_trigger; // trigger nmi when IR = this value
	
	int     reset_time;
	bool    last_iowrite;
  
  public:
	sc_in<bool>   clk;
	
	sc_out<bool>	reset_n;
	sc_out<bool>	wait_n;
	sc_out<bool>	int_n;
	sc_out<bool>	nmi_n;
	sc_out<bool>	busrq_n;
	sc_in<bool>	m1_n;
	sc_in<bool>	mreq_n;
	sc_in<bool>	iorq_n;
	sc_in<bool>	rd_n;
	sc_in<bool>	wr_n;
	sc_in<bool>	halt_n;
	sc_in<bool>	busak_n;
	sc_out<uint32_t>	di_resp; 
	sc_in<uint32_t>	dout;
	sc_in<uint32_t>	addr;
	
	void event();
	
	SC_CTOR(tv_responder) {
		SC_METHOD(event);
		sensitive << clk.pos();
		
		buf_ptr = 0;
		cur_timeout = 0;
		max_timeout = 10000;
		timeout_ctl = 1;
		int_countdown = 0;
		nmi_countdown = 0;
		nmi_trigger = 0;
		reset_time = 16;
		last_iowrite = false;
	}
};
	
#endif /*TV_RESPONDER_H_*/
